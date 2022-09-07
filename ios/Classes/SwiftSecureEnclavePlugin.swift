import Flutter
import UIKit


@available(iOS 11.3, *)
public class SwiftSecureEnclavePlugin: NSObject, FlutterPlugin {
    let seCore = SECore()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger())
        let instance = SwiftSecureEnclavePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
        case "generateKeyPair":
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let accessControlParam = AccessControlFactory(value: param!["accessControl"] as! Dictionary<String, Any>).build()
                                
                _ = try seCore.generateKeyPair(accessControlParam: accessControlParam)
                result(resultSuccess(data:true))
            } catch {
                result(resultError(error:error))
            }
            
        case "removeKey":
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let tag = param!["tag"] as! String
                
                
                let isSuccess = try seCore.removeKey(tag: tag)
                result(resultSuccess(data:isSuccess))
            } catch {
                result(resultError(error:error))
            }
            
        case "isKeyCreated":
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let tag = param!["tag"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                
                let key = try seCore.isKeyCreated(tag: tag, password: password)
                result(resultSuccess(data:key!))
            } catch {
                result(resultSuccess(data:false))
            }
            
        case "getPublicKey":
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let tag = param!["tag"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                
                let key = try seCore.getPublicKey(tag: tag, password: password)
                result(resultSuccess(data:key!))
            } catch {
                result(resultError(error:error))
            }
            
        case "encrypt" :
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let message = param!["message"] as! String
                let tag = param!["tag"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                
                let encrypted = try seCore.encrypt(message: message, tag: tag, password: password)
                result(resultSuccess(data:encrypted))
            } catch {
                result(resultError(error:error))
            }
            
        case "encryptWithPublicKey" :
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let message = param!["message"] as! String
                let publicKey = param!["publicKey"] as! String
              
                let encrypted = try seCore.encryptWithPublicKey(message: message, publicKey: publicKey)
                result(resultSuccess(data:encrypted))
            } catch {
                result(resultError(error:error))
            }
            
        case "decrypt" :
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let message = param!["message"] as! FlutterStandardTypedData
                let tag = param!["tag"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                let decrypted = try seCore.decrypt(message: message.data, tag: tag, password: password)
                result(resultSuccess(data:decrypted))
            } catch {
                result(resultError(error:error))
            }
            
        case "sign" :
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let message = param!["message"] as! FlutterStandardTypedData
                let tag = param!["tag"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                
                let signature = try seCore.sign(tag: tag, password: password, message: message.data
                )
                
                result(resultSuccess(data:signature))
            } catch {
                result(resultError(error:error))
            }
            
        case "verify" :
            do{
                let param = call.arguments as? Dictionary<String, Any>
                let tag = param!["tag"] as! String
                let signatureText = param!["signature"] as! String
                let plainText = param!["plainText"] as! String
                var password : String? = nil
                if let pwd = param!["password"] as? String {
                    password = pwd
                }
                
                let signature = try seCore.verify(
                    tag: tag, password: password, plainText: plainText, signature: signatureText
                )
                
                result(resultSuccess(data:signature))
            } catch {
                result(resultError(error:error))
            }
       
        default:
            return
        }
        
    }
}
