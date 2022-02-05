//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import SwiftUI

public struct Provider<Provider, Content: View>: View {
    
    @EnvironmentObject var multiProvider: MultiProvider
    let content: (Provider) -> Content
    
    public init(@ViewBuilder builder: @escaping (Provider) -> Content) {
        self.content = builder
    }
    
    public var body: some View {
        content(multiProvider.provide(instanceOf: Provider.self))
    }

}

open class MultiProvider: ObservableObject {
    
    public init() {
        
    }
    
    open func provide<T>(instanceOf: T.Type) -> T {
        fatalError()
    }
    
}
