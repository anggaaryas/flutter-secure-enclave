//
//  core.swift
//  secure_enclave
//
//  Created by Angga Arya Saputra on 23/06/22.
//

import Foundation
import LocalAuthentication
import CommonCrypto

class Core{
    var key: SecKey?
    var cipherTextData: Data?
    var signature: Data?
    
    enum CustomError: Error {
        case runtimeError(String)
    }
    
    static func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]

        SecItemDelete(query as CFDictionary)
    }
    
    static func makeAndStoreKey(name: String,
                                requiresBiometry: Bool) throws -> SecKey {
        removeKey(name: name)

        let flags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            flags = requiresBiometry ?
                [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
        } else {
            flags = requiresBiometry ?
                [.privateKeyUsage, .touchIDCurrentSet] : .privateKeyUsage
        }
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            flags,
                                            nil)!
        let tag = name.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag,
                kSecAttrAccessControl as String     : access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        if #available(iOS 10.0, *) {
            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                throw error!.takeRetainedValue() as Error
            }
            
            return privateKey
        } else {
            throw error!.takeRetainedValue() as Error
        }
    }
    
    static func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    private func prepareKey(keyName: String, isRequiresBiometric: Bool) -> Bool {
//        defer {
//            showPublicKey()
//        }
        key = Core.loadKey(name: keyName)
        guard key == nil else {
            return true
        }
        do {
            key = try Core.makeAndStoreKey(name: keyName,
                                                     requiresBiometry: isRequiresBiometric)
            return true
        } catch _ {
            return false
        }
    }
    
    static func getBioSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        if #available(iOS 11.3, *) {
            access = SecAccessControlCreateWithFlags(nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                &error)
        } else {
            access = SecAccessControlCreateWithFlags(nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .touchIDCurrentSet,
                &error)
        }
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }
    
    private func generatePairKey(tag: Data) throws -> Bool {
        var accessError: Unmanaged<CFError>?
        let flags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            flags =
                [.privateKeyUsage, .biometryCurrentSet]
        } else {
            flags = 
                [.privateKeyUsage, .touchIDCurrentSet]
        }
        let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &accessError
        ) as Any
        
        if let error = accessError {
            throw error.takeRetainedValue() as Error
        }
        
        let attributes = [
                kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                kSecAttrKeySizeInBits as String     : 256,
                kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
                kSecPrivateKeyAttrs as String : [
                    kSecAttrIsPermanent as String       : true,
                    kSecAttrApplicationTag as String    : tag,
                    kSecAttrAccessControl as String     : access
                ]
        ] as CFDictionary
        
        var createKeyError: Unmanaged<CFError>?
        
        if #available(iOS 10.0, *) {
            
            SecKeyCreateRandomKey(attributes as CFDictionary, &createKeyError)
            
            if let error = createKeyError {
                throw error.takeRetainedValue() as Error
            }
            
            
            return true
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10")
        }

    }
    
    
    func getPublicKeyString(tag: String) throws -> String? {
        if #available(iOS 10.0, *) {
            guard let key = key, let publicKey = SecKeyCopyPublicKey(key) else {
                return nil
            }
            var error: Unmanaged<CFError>?
            if let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
                return keyData.hexDescription
            } else {
                return nil
            }
        } else {
            throw CustomError.runtimeError("OS < 10")
        }
    }
    
//    @available(iOS 11.0, *)
//    private func getPrivateKey(tag: Data) throws -> SecKey? {
//        guard prepareKey(tag: <#T##String#>) else {
//            return nil
//        }
//
//        guard let publicKey = SecKeyCopyPublicKey(key!) else {
//            return nil
//        }
//
//        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
//        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
//            return nil
//        }
//        var error: Unmanaged<CFError>?
//        cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm,
//                                                   tag as CFData,
//                                                   &error) as Data?
//        guard cipherTextData != nil else {
//            return key
//        }
//        return key
//    }
    
    
    func encrypt(tag: String , message: String, isRequiresBiometric: Bool) throws -> FlutterStandardTypedData? {
        if #available(iOS 11.0, *) {
            guard prepareKey(keyName: tag, isRequiresBiometric: isRequiresBiometric) else {
                return nil
            }
            
            guard let publicKey = SecKeyCopyPublicKey(key!) else {
                throw CustomError.runtimeError("Failed to get public key")
            }
            let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw CustomError.runtimeError("Algorithm not suppoort")
            }
            var error: Unmanaged<CFError>?
            let clearTextData = message.data(using: .utf8)!
            cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm,
                                                       clearTextData as CFData,
                                                       &error) as Data?
            guard cipherTextData != nil else {
                return nil
            }
//            let cipherTextHex = cipherTextData?.hexDescription
            return FlutterStandardTypedData(bytes: cipherTextData!)
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10")
        }
    }
    
    
    func decrypt(tag: String, message: Data, isRequiresBiometric: Bool) throws -> String? {
        if #available(iOS 11.0, *) {
            guard prepareKey(keyName: tag, isRequiresBiometric: isRequiresBiometric) else {
                return nil
            }
            
            guard cipherTextData != nil else {
                throw CustomError.runtimeError("No Decrypt Data")
            }
            
            let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            var clearText: String?
            
            guard SecKeyIsAlgorithmSupported(self.key!, .decrypt, algorithm) else {
                throw CustomError.runtimeError("Algorithm not supported")
            }
            
//            DispatchQueue.global().async {
                var error: Unmanaged<CFError>?
                let clearTextData = SecKeyCreateDecryptedData(self.key!,
                                                              algorithm,
                                                              self.cipherTextData! as CFData,
                                                              &error) as Data?
//                DispatchQueue.main.async {
                    guard clearTextData != nil else {
                        throw CustomError.runtimeError("Can't decrypt data")
                    }
                    clearText = String(decoding: clearTextData!, as: UTF8.self)
//                }
//            }
            return clearText
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10")
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
