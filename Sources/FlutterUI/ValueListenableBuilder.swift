//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import SwiftUI

/// https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html
public struct ValueListenableBuilder<VL: ObservableObject, Content: View>: View {
    
    @ObservedObject var listenable: VL
    let content: (VL) -> Content
    
    public init(_ listenable: VL, @ViewBuilder builder: @escaping (VL) -> Content) {
        _listenable = .init(wrappedValue: listenable)
        self.content = builder
    }
    
    public var body: some View {
        content(listenable)
    }
    
}
