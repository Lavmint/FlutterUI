//
//  File.swift
//  
//
//  Created by Alexey Averkin on 09.03.2022.
//

import Foundation

open class MultiProvider: ObservableObject {
    
    public init() {
        
    }
    
    open func provide<T>(instanceOf: T.Type) -> T {
        fatalError()
    }
    
}
