import Flutter
import UIKit
//
//@available(iOS 11.3, *)
//public class SwiftSecureEnclavePlugin: NSObject, FlutterPlugin {
//    let core = Core()
//
//  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger())
//    let instance = SwiftSecureEnclavePlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
//  }
//
//  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//      switch call.method{
//      case "createKey":
//          let param = call.arguments as? Dictionary<String, Any>
//          let accessControlParam = AccessControlFactory(value: param!["accessControl"] as! Dictionary<String, Any>).build()
//
//          do{
//              try core.createKey(accessControlParam: accessControlParam)
//              result(resultSuccess(data:""))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//      case "checkKey":
//          let param = call.arguments as? Dictionary<String, Any>
//          let tag = param!["tag"] as! String
//
//          let isAvailable = core.checkKey(tag: tag)
//          result(resultSuccess(data: isAvailable))
//
//      case "encrypt" :
//          let param = call.arguments as? Dictionary<String, Any>
//          let message = param!["message"] as! String
//          let tag = param!["tag"] as! String
//
//          do{
//              let encrypted = try core.encrypt(message: message, tag: tag)
//              result(resultSuccess(data:encrypted))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//      case "encryptWithCustomPublicKey" :
//          let param = call.arguments as? Dictionary<String, Any>
//          let message = param!["message"] as! String
//          let publicKeyString = param!["publicKeyString"] as! String
//
//          do{
//              let encrypted = try core.encrypt(message: message,
//                                               publicKeyString: publicKeyString)
//              result(resultSuccess(data:encrypted))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//
//      case "decrypt" :
//          let param = call.arguments as? Dictionary<String, Any>
//          let message = param!["message"] as! FlutterStandardTypedData
//          let tag = param!["tag"] as! String
//
//          var password : String? = nil
//          if let pwd = param!["password"] as? String {
//              password = pwd
//          }
//
//          do{
//              let decrypted = try core.decrypt(message: message.data, tag: tag, password: password)
//              result(resultSuccess(data:decrypted))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//      case "getPublicKeyString":
//          let param = call.arguments as? Dictionary<String, Any>
//          let tag = param!["tag"] as! String
//
//          do{
//              let key = try core.getPublicKeyString(tag: tag)
//              result(resultSuccess(data:key))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//      case "removeKey":
//          let param = call.arguments as? Dictionary<String, Any>
//          let tag = param!["tag"] as! String
//
//          print(tag)
//
//          do{
//              let isSuccess = try core.removeKey(name: tag)
//              print(isSuccess)
//              result(resultSuccess(data:isSuccess))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//      case "cobaError":
////          core.authenticateTapped()
//          result(MethodResult(error: ErrorHandling(code: 100, desc: "Ini hanya percobaan error"), data: nil).build())
//
//      default:
//          return
//      }
//
//  }
//}



@available(iOS 11.3, *)
public class SwiftSecureEnclavePlugin: NSObject, FlutterPlugin {
    let seCore = SECore()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_enclave", binaryMessenger: registrar.messenger())
    let instance = SwiftSecureEnclavePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
//    // create and store private key to secure enclave
//    func createKey(accessControlParam: AccessControlParam) throws -> SecKey
//
//    // remove key from secure enclave
//    func removeKey(tag: String) throws -> Bool
//
//    // get SecKey key from secure enclave
//    func getSecKey(tag: String, password: String?) throws -> SecKey?
//
//    // encryption
//    func encrypt(message: String, tag: String, password: String?) throws -> FlutterStandardTypedData?
//
//    // decryption
//    func decrypt(message: String, tag: String, password: String?)  throws -> String?
    
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method{
      case "createKey":
          do{
              let param = call.arguments as? Dictionary<String, Any>
              let accessControlParam = AccessControlFactory(value: param!["accessControl"] as! Dictionary<String, Any>).build()
              
              print(param!["accessControl"] ?? "--" )
              
              try seCore.createKey(accessControlParam: accessControlParam)
              result(resultSuccess(data:""))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
      case "removeKey":
          do{
              let param = call.arguments as? Dictionary<String, Any>
              let tag = param!["tag"] as! String
              
              print(tag)
              
              let isSuccess = try seCore.removeKey(tag: tag)
              print(isSuccess)
              result(resultSuccess(data:isSuccess))
          } catch {
              print("Error info: \(error)")
              result(resultError(error:error))
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
              print("Error info: \(error)")
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
              print("Error info: \(error)")
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
              print("Error info: \(error)")
              result(resultError(error:error))
          }
          
//      case "getPublicKeyString":
//          do{
//              let param = call.arguments as? Dictionary<String, Any>
//              let tag = param!["tag"] as! String
//              let key = try core.getPublicKeyString(tag: tag)
//              result(resultSuccess(data:key))
//          } catch {
//              print("Error info: \(error)")
//              result(resultError(error:error))
//          }
//
//
//      case "cobaError":
////          core.authenticateTapped()
//          result(MethodResult(error: ErrorHandling(code: 100, desc: "Ini hanya percobaan error"), data: nil).build())
//
      default:
          return
      }
   
  }
}
