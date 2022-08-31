//
//  AccessControlParam.swift
//  secure_enclave
//
//  Created by Angga Arya Saputra on 05/07/22.
//

import Foundation

@available(iOS 11.3, *)
class AccessControlParam{
    let password: String?
    let tag : String
    var option: SecAccessControlCreateFlags = []
    
    init(value: Dictionary<String, Any>){
        print(value)
        self.password = value["password"] as? String
        self.tag = value["tag"] as! String
        buildOption(optionsParam: value["options"] as! Array<String>)
    }
    
    func buildOption(optionsParam: Array<String>) {
        for opt in optionsParam{
            switch opt {
            case "devicePasscode":
                option.insert(.devicePasscode)
            case "biometryAny":
                option.insert(.biometryAny)
            case "biometryCurrentSet":
                option.insert(.biometryCurrentSet)
            case "userPresence":
                option.insert(.userPresence)
            case "privateKeyUsage":
                option.insert(.privateKeyUsage)
            case "applicationPassword":
                option.insert(.applicationPassword)
            case "or":
                option.insert(.or)
            case "and":
                option.insert(.and)
            default:
                break
            }
        }
    }
    
}
