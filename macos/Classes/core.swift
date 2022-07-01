//
//  core.swift
//  secure_enclave
//
//  Created by Angga Arya Saputra on 23/06/22.
//

import Foundation
import FlutterMacOS

class Core{
    
    enum CustomError: Error {
        case runtimeError(String)
    }
    
    func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]

        SecItemDelete(query as CFDictionary)
    }
    
    private func makeAndStorePrivateKey(name: String,
                                requiresBiometry: Bool) throws -> SecKey {
        if #available(macOS 10.12.1, *) {
            let flags: SecAccessControlCreateFlags
            if #available(macOS 10.13.4, *) {
                flags = requiresBiometry ?
                [.privateKeyUsage, .userPresence] : .privateKeyUsage
            } else {
                flags = requiresBiometry ?
                    [.privateKeyUsage, .userPresence] : .privateKeyUsage
            }
            
            var accessError: Unmanaged<CFError>?
            
            let access =
                SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                flags,
                                                &accessError)!
            
            if let error = accessError {
                throw error.takeRetainedValue() as Error
            }
            
            let tag = name.data(using: .utf8)
            if let tag = tag {
                
                let attributes : CFDictionary
                
                if TARGET_OS_SIMULATOR != 0 {
                    // target is current running in the simulator
                    attributes = [
                            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
                            kSecAttrKeySizeInBits as String     : 256,
                            kSecPrivateKeyAttrs as String : [
                                kSecAttrApplicationTag as String    : tag,
                                kSecAttrAccessControl as String     : access
                            ]
                    ] as CFDictionary
                } else {
                    attributes = [
                        kSecAttrTokenID as String:              kSecAttrTokenIDSecureEnclave,
                        kSecAttrKeyType as String:              kSecAttrKeyTypeEC,
                        kSecAttrKeySizeInBits as String:        256,
                        kSecAttrApplicationTag as String:       tag,
                        kSecPrivateKeyAttrs as String: [
                            kSecAttrIsPermanent as String:      true,
                            kSecAttrAccessControl as String:    access,
                        ],
                    ]  as CFDictionary
                }
                
                var error: Unmanaged<CFError>?
                if #available(macOS 10.13.4, *) {
                    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                        throw error!.takeRetainedValue() as Error
                    }
                    return privateKey
                } else {
                    throw CustomError.runtimeError("OS < 10.13.4")
                }
            } else {
                // tag error
                throw CustomError.runtimeError("Invalid TAG") as Error
            }
        } else {
            throw CustomError.runtimeError("OS < 10.12.1")
        }
    }
    
    private func loadKey(name: String) throws -> SecKey? {
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
            if status == errSecNotAvailable || status == errSecItemNotFound {
                return nil
            } else {
                if #available(macOS 10.13.4, *) {
                    throw  NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: SecCopyErrorMessageString(status,nil) ?? "Undefined error"])
                } else {
                    throw CustomError.runtimeError("Failed Load key")
                }
            }
        }
        
 
        return (item as! SecKey)
      
    }
    
    private func preparePrivateKey(keyName: String, isRequiresBiometric: Bool) throws -> SecKey {
        do {
            var key = try loadKey(name: keyName)
            if key == nil {
                key = try makeAndStorePrivateKey(name: keyName, requiresBiometry: isRequiresBiometric)
            }
            return key!
        } catch {
            throw error
        }
    }
    
    private func getBioSecAccessControl() throws -> SecAccessControl {
        if #available(macOS 10.12.1, *) {
            var access: SecAccessControl?
            var error: Unmanaged<CFError>?
            if #available(macOS 10.13.4, *){
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
        } else {
            throw CustomError.runtimeError("OS < 10.12.1")
        }
    }
    
    func getPublicKeyString(tag: String, isRequiresBiometric: Bool) throws -> String? {
        if #available(macOS 10.12, *) {
            let privateKey : SecKey
            let publicKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(keyName: tag, isRequiresBiometric: isRequiresBiometric)
                publicKey = try getPublicKey(privateKey: privateKey)
            } catch{
                throw error
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

    private func getPublicKey(privateKey: SecKey) throws -> SecKey {
        if #available(macOS 10.12, *) {
            if let publicKey = SecKeyCopyPublicKey(privateKey) {
                return publicKey
            } else {
                throw CustomError.runtimeError("Failed get public key from private key")
            }
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10")
        }
    }
    
    
    func encrypt(tag: String , message: String, isRequiresBiometric: Bool) throws -> FlutterStandardTypedData? {
        if #available(macOS 10.13, *){
            let privateKey : SecKey
            let publicKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(keyName: tag, isRequiresBiometric: isRequiresBiometric)
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
                print(cipherTextData.bytes)
                return FlutterStandardTypedData(bytes: cipherTextData)
            } else {
                throw CustomError.runtimeError("Harusnya bisa encrypt")
            }
            
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10.12")
        }
    }
    
    
    func decrypt(tag: String, message: Data, isRequiresBiometric: Bool) throws -> String? {
        if #available(macOS 10.13, *) {
            let privateKey : SecKey
            
            do{
                privateKey = try preparePrivateKey(keyName: tag, isRequiresBiometric: isRequiresBiometric)
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

            if let clearTextData = clearTextData {
                let clearText = String(decoding: clearTextData, as: UTF8.self)

                return clearText
            } else {
                throw CustomError.runtimeError("Can't decrypt data")
            }
            
            
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10.13")
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
