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
    
    private func generatePairKey(tag: Data) throws -> Bool {
        var accessError: Unmanaged<CFError>?
        if #available(macOS 10.13.4, *) {
            let flags: SecAccessControlCreateFlags = [ .userPresence]
            
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
                
            SecKeyCreateRandomKey(attributes, &createKeyError)
                
            if let error = createKeyError {
                throw error.takeRetainedValue() as Error
            }
                
                
            return true
            
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10.12.1")
        }
       
        

    }
    
    
    func getPublicKeyString(tag: String) throws -> String? {
        
        let publicKey : SecKey?
        
        do{
            publicKey = try getPublicKey(tag: tag)
        } catch{
            throw error
        }
        
        if let publicKey = publicKey{
                if #available(macOS 10.12, *) {
                    var err: Unmanaged<CFError>?
                    let publicKeyData = SecKeyCopyExternalRepresentation(publicKey,&err)! as Data
                    if let error = err {
                        throw error.takeRetainedValue() as Error
                    }
                    
                    return publicKeyData.base64EncodedString()
                } else {
                    // Fallback on earlier versions
                    throw CustomError.runtimeError("OS < 10.12")
                }
        } else {
            return nil
        }
        
    }
    
    private func getPublicKey(tag: String) throws -> SecKey? {
        if let tag = tag.data(using: .utf8) {
            let privateKey : SecKey?
            
            do{
                privateKey = try getPrivateKey(tag: tag)
            } catch {
                throw error
            }
            
            if #available(macOS 10.12, *) {
                guard let privateKey = privateKey, let publicKey = SecKeyCopyPublicKey(privateKey) else {
                    throw CustomError.runtimeError("Failed get public key from private key")
                }
                
                                
                return publicKey
                
            } else {
                // Fallback on earlier versions
                throw CustomError.runtimeError("OS < 10.12")
            }
            
        } else {
            throw CustomError.runtimeError("Invalid tag")
        }
    }
    
    
    private func getPrivateKey(tag: Data) throws -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true,
            kSecAttrKeySizeInBits as String     : 256,
        ]
        
        var item: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &item)
        
        if let item = item {
            return (item as! SecKey)
        } else {
                            do{
                                print("create new private key")
                                let generate = try generatePairKey(tag: tag)
                                if generate {
                                    return try getPrivateKey(tag: tag)
                                } else {
                                    throw CustomError.runtimeError("generate pair key return false")
                                }
                            } catch {
                                throw error
                            }
        }
        
    }
    
    
    func encrypt(tag: String , message: String) throws -> FlutterStandardTypedData? {
        if #available(macOS 10.13, *) {
            let publicKey :SecKey?
            
            do{
                publicKey = try getPublicKey(tag: tag)
            } catch {
                throw error
            }
            
            if let publicKey = publicKey {
                let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
                
                guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                    throw CustomError.runtimeError("Algorithm not supported")
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
                    return nil
                }

                
            } else {
                throw CustomError.runtimeError("Failed to get public key")
            }
        } else {
            // Fallback on earlier versions
            throw CustomError.runtimeError("OS < 10")
        }
    }
    
    
    func decrypt(tag: String, message: Data) throws -> String? {
        if #available(macOS 10.13, *) {
            let tag = tag.data(using: .utf8)
            if let tag = tag{
                
                let privateKey : SecKey?
                
                do{
                    privateKey = try getPrivateKey(tag: tag)
                } catch {
                    throw error
                }
                
                if let privateKey = privateKey {
                    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
                    let cipherTextData = message as CFData
                    
                    guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
                        throw CustomError.runtimeError("Algorithm not supported")
                    }
                    
                    var error: Unmanaged<CFError>?
                    let clearTextData = SecKeyCreateDecryptedData(privateKey,
                            algorithm,
                            cipherTextData,
                            &error
                    ) as Data?
                            
                    
                    if let error = error {
                        throw error.takeRetainedValue() as Error
                    }
                    
                    guard clearTextData != nil else {
                        return nil
                    }
                    
                    let clearText = String(data: clearTextData!, encoding: .utf8)
                    
                    return clearText
                            
                } else {
                    return nil
                }
            } else {
                throw CustomError.runtimeError("Failed to get public key")
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
