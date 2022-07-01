//
//  Base.swift
//  Pods-Runner
//
//  Created by Angga Arya Saputra on 01/07/22.
//

import Foundation

protocol BaseModel {
    func build() -> Dictionary<String, Any>
}

extension BaseModel {
    func build() -> Dictionary<String, Any>{
        fatalError("Not Implemented!")
    }
}
