import Flutter
import UIKit

public class SwiftSecureEnclavePlugin: NSObject, FlutterPlugin {
    let core = Core()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureEnclavePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      print(call.method)
      switch call.method{
      case "encrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          let message = param!["message"] as! String
                
          do{
              let encrypted = try core.encrypt(tag: tag, message: message)
              result(encrypted)
          } catch {
              print("Error info: \(error)")
          }
      case "decrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          let message = param!["message"] as! FlutterStandardTypedData
        
          do{
              let decrypted = try core.decrypt(tag: tag, message: message.data)
              result(decrypted)
          } catch {
              print("Error info: \(error)")
          }
          
      case "getPublicKeyString":
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          
          do{
              let key = try core.getPublicKeyString(tag: tag)
              result(key)
          } catch {
              print("Error info: \(error)")
          }
          
      default:
          return
      }
   
  }
}
