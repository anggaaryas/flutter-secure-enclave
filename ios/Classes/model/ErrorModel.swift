//
//  Error.swift
//  Pods-Runner
//
//  Created by Angga Arya Saputra on 01/07/22.
//

import Foundation


class ErrorModel : BaseModel{
    let code: Int
    let desc: String
    
    init(code: Int, desc: String){
        self.code = code
        self.desc = desc
    }
    
    init(error: Error){
        if error is CustomError {
            self.code = 0
        } else {
            self.code = (error as NSError).code
        }
        self.desc = error.localizedDescription
    }
    
    func build() -> Dictionary<String, Any> {
        return [
            "code" : NSNumber(value: code),
            "desc" : desc
        ]
    }
}

enum CustomError: Error {

    case runtimeError(String)
    
    func get() -> String {
            switch self {
            case .runtimeError(let desc):
                return desc
            }
        }
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .runtimeError:
            return NSLocalizedString("\(self.get())", comment: "Custom Error")
        }
    }
}
