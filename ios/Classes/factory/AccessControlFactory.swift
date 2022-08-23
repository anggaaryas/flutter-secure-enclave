//
//  AccessControlFactory.swift
//  Pods-Runner
//
//  Created by Angga Arya Saputra on 10/08/22.
//

import Foundation

@available(iOS 11.3, *)
class AccessControlFactory{
    let value: Dictionary<String, Any>
    
    init(value: Dictionary<String, Any>){
        self.value = value
    }
    
    func build() -> AccessControlParam{
        return AccessControlParam(value: value)
//        if (value["options"] as! Array<String>).contains("applicationPassword") {
//            return AppPasswordAccessControlParam(value: value, password: value["password"] as! String)
//        } else {
//            return AccessControlParam(value: value)
//        }
    }
}
