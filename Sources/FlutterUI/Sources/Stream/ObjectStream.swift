//
//  File.swift
//  
//
//  Created by Alexey Averkin on 03.12.2021.
//

import Foundation
import SwiftUI

public struct ObjectStream<Object: ObservableObject, Content: View>: View {
    
    @ObservedObject private var object: Object
    private let content: (Object) -> Content
    
    public init(object: Object, @ViewBuilder builder: @escaping (Object) -> Content) {
        self.object = object
        self.content = builder
    }
    
    public var body: some View {
        content(object)
    }
    
}
