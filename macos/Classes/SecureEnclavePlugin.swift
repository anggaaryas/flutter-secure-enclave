import Cocoa
import FlutterMacOS

public class SecureEnclavePlugin: NSObject, FlutterPlugin {
    let core = Core()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger)
    let instance = SecureEnclavePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      print(call.method)
            switch call.method{
      case "encrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          let message = param!["message"] as! String
          let isRequiresBiometric = param!["isRequiresBiometric"] as! Bool
                
          do{
              let encrypted = try core.encrypt(tag: tag, message: message, isRequiresBiometric: isRequiresBiometric)
              result(encrypted)
          } catch {
              print("Error info: \(error)")
          }
      case "decrypt" :
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          let message = param!["message"] as! FlutterStandardTypedData
          let isRequiresBiometric = param!["isRequiresBiometric"] as! Bool
        
          do{
              let decrypted = try core.decrypt(tag: tag, message: message.data, isRequiresBiometric: isRequiresBiometric)
              result(decrypted)
          } catch {
              print("Error info: \(error)")
          }
          
      case "getPublicKeyString":
          let param = call.arguments as? Dictionary<String, Any>
          let tag = param!["tag"] as! String
          let isRequiresBiometric = param!["isRequiresBiometric"] as! Bool
          
          do{
              let key = try core.getPublicKeyString(tag: tag, isRequiresBiometric: isRequiresBiometric)
              result(key)
          } catch {
              print("Error info: \(error)")
          }
          
      default:
          return
      }
  }
}
