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
    func createKey(accessControlParam: AccessControlParam) throws -> SecKey
    
    // remove key from secure enclave
    func removeKey(tag: String) throws -> Bool
     
    // get SecKey key from secure enclave (private method)
    func getSecKey(tag: String, password: String?) throws -> SecKey?
    
    // get publicKey key from secure enclave
    func getPublicKey(tag: String, password: String?) throws -> String?
    
    // encryption
    func encrypt(message: String, tag: String, password: String?) throws -> FlutterStandardTypedData?
    
    // decryption
    func decrypt(message: Data, tag: String, password: String?)  throws -> String?
}


@available(iOS 11.3, *)
class SECore : SECoreProtocol {
    
    func createKey(accessControlParam: AccessControlParam) throws -> SecKey  {
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
                            kSecAttrAccessControl as String     : secAttrAccessControl
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
                            kSecAttrAccessControl as String     : secAttrAccessControl
                        ]
                ]
            }
            
            // cek kalau pakai app password, tambahkan password nya
            if accessControlParam is AppPasswordAccessControlParam {
                let context = LAContext()
                context.setCredential((accessControlParam as! AppPasswordAccessControlParam).password.data(using: .utf8), type: .applicationPassword)

                parameterTemp[kSecUseAuthenticationContext as String] = context
            }
            
            // convert ke CFDictinery
            parameter = parameterTemp as CFDictionary
            
            var secKeyCreateRandomKeyError: Unmanaged<CFError>?
            
            guard let secKey = SecKeyCreateRandomKey(parameter, &secKeyCreateRandomKeyError)
            else {
                throw secKeyCreateRandomKeyError!.takeRetainedValue() as Error
            }
            
            print(secKey)
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
            context.setCredential(password.data(using: .utf8), type: .applicationPassword)
            
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
            throw CustomError.runtimeError("Harusnya bisa encrypt")
        }
        
        
    }
    
    func decrypt(message: Data, tag: String, password: String?)  throws -> String?  {
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
    
}
