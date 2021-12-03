//
//  File.swift
//  
//
//  Created by Alexey Averkin on 03.11.2021.
//

import Foundation
import Combine

@propertyWrapper
public class Subject<Value> {
    
    public let subject: CurrentValueSubject<Value, Never>
        
    public var wrappedValue: Value {
        get {
            subject.value
        }
        set {
            subject.value = newValue
        }
    }
    
    public init(wrappedValue: Value) {
        subject = .init(wrappedValue)
    }
    
    public var projectedValue: CurrentValueSubject<Value, Never>  {
        return subject
    }
    
}
