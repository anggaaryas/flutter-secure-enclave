import Flutter
import UIKit

@available(iOS 11.3, *)
public class SwiftSecureEnclavePlugin: NSObject, FlutterPlugin {
    let core = Core()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureEnclavePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method{
      case "encrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let message = param!["message"] as! String
          let accessControlParam = AccessControlParam(value: param!["accessControl"] as! Dictionary<String, Any>)
                
          do{
              let encrypted = try core.encrypt(message: message, accessControlParam: accessControlParam)
              result(resultSuccess(data:encrypted))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
      case "encryptWithCustomPublicKey" :
          let param = call.arguments as? Dictionary<String, Any>
          let message = param!["message"] as! String
          let publicKeyString = param!["publicKeyString"] as! String
                
          do{
              let encrypted = try core.encrypt(message: message,
                                               publicKeyString: publicKeyString)
              result(resultSuccess(data:encrypted))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
          
      case "decrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let message = param!["message"] as! FlutterStandardTypedData
          let accessControlParam = AccessControlParam(value: param!["accessControl"] as! Dictionary<String, Any>)
        
          do{
              let decrypted = try core.decrypt(message: message.data, accessControlParam: accessControlParam)
              result(resultSuccess(data:decrypted))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
      case "getPublicKeyString":
          let param = call.arguments as? Dictionary<String, Any>
          let accessControlParam = AccessControlParam(value: param!["accessControl"] as! Dictionary<String, Any>)
          
          do{
              let key = try core.getPublicKeyString(accessControlParam: accessControlParam)
              result(resultSuccess(data:key))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
      case "removeKey":
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          
          print(tag)
          
          do{
              let isSuccess = try core.removeKey(name: tag)
              print(isSuccess)
              result(resultSuccess(data:isSuccess))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
      case "cobaError":
          result(MethodResult(error: ErrorHandling(code: 100, desc: "Ini hanya percobaan error"), data: nil).build())
          
      default:
          return
      }
   
  }
}
