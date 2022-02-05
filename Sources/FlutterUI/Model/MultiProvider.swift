//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation

open class MultiProvider: ObservableObject {
    
    public init() {
        
    }
    
    open func provide<T>(instanceOf: T.Type) -> T {
        fatalError()
    }
    
}
