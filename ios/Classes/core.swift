//
//  core.swift
//  secure_enclave
//
//  Created by Angga Arya Saputra on 23/06/22.
//

import Foundation
import LocalAuthentication
import CommonCrypto

@available(iOS 11.3, *)
class Core{
    
//    func authenticateTapped() {
//        let context = LAContext()
//        var error: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Identify yourself!"
//
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                [weak self] success, authenticationError in
//
//                DispatchQueue.main.async {
//                    if success {
//                        print("sukses biometry")
//                    } else {
//                        // error
//                        print("error biometry")
//                    }
//                }
//            }
//        } else {
//            // no biometry
//            print("nggak ada biometry")
//        }
//    }
    
    func removeKey(name: String) throws -> Bool{
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
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
    
    private func makeAndStorePrivateKey(accessControl: AccessControlParam) throws -> SecKey {
      

        let flags: SecAccessControlCreateFlags = accessControl.option
     
        
        var accessError: Unmanaged<CFError>?
        
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,  // dynamis dari flutter
                                            flags,
                                            &accessError)!
        
        if let error = accessError {
            throw error.takeRetainedValue() as Error
        }
        
        let tag = accessControl.tag.data(using: .utf8)
        if let tag = tag {
            
            // TODO: create builder to make CFDictionary
            
            let attributes : CFDictionary
            var attrTemp: Dictionary<String, Any>
            
            if TARGET_OS_SIMULATOR != 0 {
                // target is current running in the simulator
                attrTemp = [
                        kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                        kSecAttrKeySizeInBits as String     : 256,
                        kSecPrivateKeyAttrs as String : [
                            kSecAttrIsPermanent as String       : true,
                            kSecAttrApplicationTag as String    : tag,
                            kSecAttrAccessControl as String     : access
                        ]
                ]
            } else {
                attrTemp = [
                        kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                        kSecAttrKeySizeInBits as String     : 256,
                        kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
                        kSecPrivateKeyAttrs as String : [
                            kSecAttrIsPermanent as String       : true,
                            kSecAttrApplicationTag as String    : tag,
                            kSecAttrAccessControl as String     : access
                        ]
                ]
            }
            
            // cek kalau pakai app password, tambahkan password nya
            if accessControl is AppPasswordAccessControlParam {
                let context = LAContext()
                context.setCredential((accessControl as! AppPasswordAccessControlParam).password.data(using: .utf8), type: .applicationPassword)

                attrTemp[kSecUseAuthenticationContext as String] = context
            }
            
            // convert ke CFDictinery
            attributes = attrTemp as CFDictionary
            
            var error: Unmanaged<CFError>?
            
            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                throw error!.takeRetainedValue() as Error
            }
            return privateKey
            
        } else {
            // tag error
            throw CustomError.runtimeError("Invalid TAG") as Error
        }
    }
    
    private func loadKey(name: String, password: String?) throws -> SecKey? {
        let tag = name.data(using: .utf8)!
        
        var query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
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
    
    func checkKey(tag: String) -> bool {
        do {
            let key = try loadKey(name: tag, password: nil)
            if let key = key {
                return true
            }else {
                return false
            }
        } catch {
            return false
        }
    }
    
    private func preparePrivateKey(tag: String, password: String?) throws -> SecKey {
        do {
            let key = try loadKey(name: tag, password: password)
            if let key = key {
                return key
            }else {
                throw CustomError.runtimeError("Seharusnya nggak null!")
            }
        } catch {
            throw error
        }
    }
    
    func createKey(accessControlParam: AccessControlParam) throws {
       _ = try makeAndStorePrivateKey(accessControl: accessControlParam)
    }
    
    func getPublicKeyString(tag: String) throws -> String? {
       
            let privateKey : SecKey
            let publicKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(tag: tag, password: nil)
                publicKey = try getPublicKey(privateKey: privateKey)
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

    private func getPublicKey(privateKey: SecKey) throws -> SecKey {
     
            if let publicKey = SecKeyCopyPublicKey(privateKey) {
                return publicKey
            } else {
                throw CustomError.runtimeError("Failed get public key from private key")
            }
      
    }
    
    private func retrievePublicKeyFromString(publicKeyString: String) throws -> SecKey{

            let publicKeyData = Data(base64Encoded: publicKeyString)!
            
            let attributes: [String:Any] =
                [
                    kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                    kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                    kSecAttrKeySizeInBits as String: 256,
                ]
            var error: Unmanaged<CFError>?
            let secKey = SecKeyCreateWithData(publicKeyData as CFData, attributes as CFDictionary, &error)
            
            if let error = error {
                throw error.takeRetainedValue() as Error
            }
            
            if let publicKey = secKey{
                return publicKey
            } else {
                throw CustomError.runtimeError("Public key null!")
                
            }
    }
    
    
    func encrypt( message: String, publicKeyString: String) throws -> FlutterStandardTypedData? {

            let publicKey : SecKey
            
            do{
                publicKey = try retrievePublicKeyFromString(publicKeyString: publicKeyString)
            } catch {
                throw error
            }
            
            let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw CustomError.runtimeError("Algorithm not suppoort")
            }
            var error: Unmanaged<CFError>?
            let clearTextData = message.data(using: .utf8)!
            let cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm,
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
    
    func encrypt( message: String, tag: String) throws -> FlutterStandardTypedData? {
        
            let privateKey : SecKey
            let publicKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(tag: tag, password: nil)
                publicKey = try getPublicKey(privateKey: privateKey)
            } catch{
                throw error
            }
            
            let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw CustomError.runtimeError("Algorithm not suppoort")
            }
            var error: Unmanaged<CFError>?
            let clearTextData = message.data(using: .utf8)!
            let cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm,
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
    
    
    func decrypt(message: Data, tag: String, password: String?) throws -> String? {

            let privateKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(tag: tag, password: password)
            } catch{
                throw error
            }
            
            let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            let cipherTextData = message as CFData
            
            guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
                throw CustomError.runtimeError("Algorithm not supported")
            }
            
            var error: Unmanaged<CFError>?
            let clearTextData = SecKeyCreateDecryptedData(privateKey,
                                                              algorithm,
                                                              cipherTextData,
                                                              &error) as Data?
            
            if let error = error {
                throw error.takeUnretainedValue() as Error
            }

            if let clearTextData = clearTextData {
                let clearText = String(decoding: clearTextData, as: UTF8.self)

                return clearText
            } else {
                throw CustomError.runtimeError("Can't decrypt data")
            }
            
            

    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    var bytes: [UInt8] {
            return [UInt8](self)
        }
}

extension Array where Element == UInt8 {
    var data: Data {
        return Data(self)
    }
}
