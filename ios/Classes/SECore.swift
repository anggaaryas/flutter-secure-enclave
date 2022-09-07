//
//  SECore.swift
//  secure_enclave
//
//  Created by Angga Arya Saputra on 18/08/22.
//

import Foundation
import LocalAuthentication

// Abstraction/Protocol class of SECore
@available(iOS 11.3, *)
protocol SECoreProtocol {
    // create and store private key to secure enclave
    func generateKeyPair(accessControlParam: AccessControlParam) throws -> SecKey
    
    // remove key from secure enclave
    func removeKey(tag: String) throws -> Bool
    
    // get SecKey key from secure enclave (private method)
    func getSecKey(tag: String, password: String?) throws -> SecKey?
    
    // get status SecKey key from secure enclave (private method)
    func isKeyCreated(tag: String, password: String?) throws -> Bool?
    
    // get publicKey key from secure enclave
    func getPublicKey(tag: String, password: String?) throws -> String?
    
    // encryption
    func encrypt(message: String, tag: String, password: String?) throws -> FlutterStandardTypedData?
    
    // encryption with base64 Public key
    func encryptWithPublicKey(message: String, publicKey: String) throws -> FlutterStandardTypedData?
    
    // decryption
    func decrypt(message: Data, tag: String, password: String?) throws -> String?
    
    // sign
    func sign(tag: String, password: String?, message: Data) throws -> String?
    
    // verify
    func verify(tag: String, password: String?, plainText: String, signature: String) throws -> Bool
}


@available(iOS 11.3, *)
class SECore : SECoreProtocol {
    
    func generateKeyPair(accessControlParam: AccessControlParam) throws -> SecKey  {
        // options
        let secAccessControlCreateFlags: SecAccessControlCreateFlags = accessControlParam.option
        let secAttrApplicationTag: Data? = accessControlParam.tag.data(using: .utf8)
        var accessError: Unmanaged<CFError>?
        let secAttrAccessControl =
        SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            // dynamis dari flutter
            secAccessControlCreateFlags,
            &accessError
        )
        
        let parameter : CFDictionary
        var parameterTemp: Dictionary<String, Any>
        
        if let error = accessError {
            throw error.takeRetainedValue() as Error
        }
        
        if let secAttrApplicationTag = secAttrApplicationTag {
            if TARGET_OS_SIMULATOR != 0 {
                // target is current running in the simulator
                parameterTemp = [
                    kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                    kSecAttrKeySizeInBits as String     : 256,
                    kSecPrivateKeyAttrs as String       : [
                        kSecAttrIsPermanent as String       : true,
                        kSecAttrApplicationTag as String    : secAttrApplicationTag,
                        kSecAttrAccessControl as String     : secAttrAccessControl!
                    ]
                ]
            } else {
                parameterTemp = [
                    kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                    kSecAttrKeySizeInBits as String     : 256,
                    kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
                    kSecPrivateKeyAttrs as String : [
                        kSecAttrIsPermanent as String       : true, 
                        kSecAttrApplicationTag as String    : secAttrApplicationTag,
                        kSecAttrAccessControl as String     : secAttrAccessControl!
                    ]
                ]
            }
            
            // cek kalau pakai app password, tambahkan password nya
            if accessControlParam.option.contains(.applicationPassword) {
               let context = LAContext()
               var newPassword : Data?
               if accessControlParam.password != "" {
                   newPassword = accessControlParam.password?.data(using: .utf8)
               }
               context.setCredential(newPassword, type: .applicationPassword)
                
               parameterTemp[kSecUseAuthenticationContext as String] = context
            }
            
            // convert ke CFDictinery
            parameter = parameterTemp as CFDictionary
            
            var secKeyCreateRandomKeyError: Unmanaged<CFError>?
            
            guard let secKey = SecKeyCreateRandomKey(parameter, &secKeyCreateRandomKeyError)
                    
            else {
                throw secKeyCreateRandomKeyError!.takeRetainedValue() as Error
            }
            
            return secKey
        } else {
            // tag error
            throw CustomError.runtimeError("Invalid TAG") as Error
        }
    }
    
    func removeKey(tag: String) throws -> Bool {
        let secAttrApplicationTag : Data = tag.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : secAttrApplicationTag
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            if status == errSecNotAvailable || status == errSecItemNotFound {
                return false
            } else {
                throw  NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: SecCopyErrorMessageString(status,nil) ?? "Undefined error"])
            }
        }
        
        return true
    }
    
    internal func getSecKey(tag: String, password: String?) throws -> SecKey?  {
        let secAttrApplicationTag = tag.data(using: .utf8)!
        
        var query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : secAttrApplicationTag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecMatchLimit as String            : kSecMatchLimitOne ,
            kSecReturnRef as String             : true
        ]
        
        if let password = password {
            let context = LAContext()
            var newPassword : Data?
            if password != "" {
                newPassword = password.data(using: .utf8)
            }
            context.setCredential(newPassword, type: .applicationPassword)
             
            query[kSecUseAuthenticationContext as String] = context
        }
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw  NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: SecCopyErrorMessageString(status,nil) ?? "Undefined error"])
        }
        
        
        if let item = item {
            return (item as! SecKey)
        } else {
            return nil
        }
    }
    
    func isKeyCreated(tag: String, password: String?) throws -> Bool?  {
        do{
            let result =  try getSecKey(tag: tag, password: password)
            return result != nil ? true : false
        } catch{
            throw error
        }
    }
    
    func getPublicKey(tag: String, password: String?) throws -> String? {
        let secKey : SecKey
        let publicKey : SecKey
        
        do{
            secKey = try getSecKey(tag: tag, password: password)!
            publicKey = SecKeyCopyPublicKey(secKey)!
        } catch{
            throw error
        }
        
        var error: Unmanaged<CFError>?
        if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
            return keyData.base64EncodedString()
        } else {
            return nil
        }
    }
    
    func encrypt(message: String, tag: String, password: String?) throws -> FlutterStandardTypedData?  {
        let secKey : SecKey
        let publicKey : SecKey
        
        do{
            secKey = try getSecKey(tag: tag, password: password)!
            publicKey = SecKeyCopyPublicKey(secKey)!
        } catch{
            throw error
        }
        
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw CustomError.runtimeError("Algorithm not suppoort")
        }
        
        var error: Unmanaged<CFError>?
        let clearTextData = message.data(using: .utf8)!
        let cipherTextData = SecKeyCreateEncryptedData(
            publicKey,
            algorithm,
            clearTextData as CFData,
            &error) as Data?
        
        if let error = error {
            throw error.takeRetainedValue() as Error
        }
        
        if let cipherTextData = cipherTextData {
            return FlutterStandardTypedData(bytes: cipherTextData)
        } else {
            throw CustomError.runtimeError("Cannot encrypt data")
        }
    }
    
    func encryptWithPublicKey(message: String, publicKey: String) throws -> FlutterStandardTypedData?  {
        let newPublicKeyData = Data(base64Encoded: publicKey, options: [])
        let newPublicParams: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256
        ]
        guard let newPublicKey = SecKeyCreateWithData(newPublicKeyData! as CFData, newPublicParams as CFDictionary, nil) else {
            throw CustomError.runtimeError("Cannot encrypt data")
        }
        
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(newPublicKey, .encrypt, algorithm) else {
            throw CustomError.runtimeError("Algorithm not suppoort")
        }
        
        var error: Unmanaged<CFError>?
        let clearTextData = message.data(using: .utf8)!
        let cipherTextData = SecKeyCreateEncryptedData(
            newPublicKey,
            algorithm,
            clearTextData as CFData,
            &error) as Data?
        
        if let error = error {
            throw error.takeRetainedValue() as Error
        }
        
        if let cipherTextData = cipherTextData {
            return FlutterStandardTypedData(bytes: cipherTextData)
        } else {
            throw CustomError.runtimeError("Cannot encrypt data")
        }
    }
    
    func decrypt(message: Data, tag: String, password: String?) throws -> String?  {
        let secKey : SecKey
        
        do{
            secKey = try getSecKey(tag: tag, password: password)!
        } catch{
            throw error
        }
        
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        let cipherTextData = message as CFData
        
        guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
            throw CustomError.runtimeError("Algorithm not supported")
        }
        
        var error: Unmanaged<CFError>?
        let plainTextData = SecKeyCreateDecryptedData(
            secKey,
            algorithm,
            cipherTextData,
            &error) as Data?
        
        if let error = error {
            throw error.takeUnretainedValue() as Error
        }
        
        if let plainTextData = plainTextData {
            let plainText = String(decoding: plainTextData, as: UTF8.self)
            return plainText
        } else {
            throw CustomError.runtimeError("Can't decrypt data")
        }
    }
    
    func sign(tag: String, password: String?, message: Data) throws -> String?{
        let secKey : SecKey
        
        do{
            secKey = try getSecKey(tag: tag, password: password)!
        } catch {
            throw error
        }

        var error: Unmanaged<CFError>?
        guard let signData = SecKeyCreateSignature(
            secKey,
            SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256,
            message as CFData, &error) else {
            if let e = error {
              throw e.takeUnretainedValue() as Error
            }
            throw CustomError.runtimeError("Can't sign data")
        } //2
        
        let signedData = signData as Data
        let signedString = signedData.base64EncodedString(options: [])
        return signedString
    }
    
    
    func verify(tag: String, password: String?, plainText: String, signature: String) throws -> Bool {
        let externalKeyB64String : String
        
        guard Data(base64Encoded: signature) != nil else {
            return false
        }
        
        do{
            externalKeyB64String = try getPublicKey(tag: tag, password: password)!
        } catch{
            throw error
        }
        
        //convert b64 key back to usable key
        let newPublicKeyData = Data(base64Encoded: externalKeyB64String, options: [])
        let newPublicParams: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256
        ]
        guard let newPublicKey = SecKeyCreateWithData(newPublicKeyData! as CFData, newPublicParams as CFDictionary, nil) else {
            return false
        }
        
        guard let messageData = plainText.data(using: String.Encoding.utf8) else {
            return false
        }
        
        guard let signatureData = Data(base64Encoded: signature, options: []) else {
            return false
        }
        
        let verify = SecKeyVerifySignature(newPublicKey, SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256, messageData as CFData, signatureData as CFData, nil)
        return verify
    }
    
}
