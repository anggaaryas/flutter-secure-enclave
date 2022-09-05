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
    }
}
