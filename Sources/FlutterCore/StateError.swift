//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation

/// https://api.flutter.dev/flutter/dart-core/StateError-class.html
public struct StateError: LocalizedError {
    
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
    
}
