//
//  MethodResult.swift
//  Pods-Runner
//
//  Created by Angga Arya Saputra on 01/07/22.
//

import Foundation

class MethodResult : BaseModel{
    let error: ErrorHandling?
    let data: Any?
    
    init(error: ErrorHandling?, data: Any?){
        self.error = error
        self.data = data
    }
    
    func build() -> Dictionary<String, Any?> {
        return [
            "error" : error?.build(),
            "data": data
        ]
    }
}


func resultSuccess(data: Any?) -> Dictionary<String, Any?> {
    let result = MethodResult(error: nil, data: data);
    return result.build()
}

func resultError(error: Error) -> Dictionary<String, Any?> {
    let result = MethodResult(error: ErrorHandling(error: error), data: nil);
    return result.build()
}
