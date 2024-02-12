//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import SwiftUI

/// https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html
public struct ListenableObject<VL: ObservableObject, Content: View>: View {

    @ObservedObject public var listenable: VL
    public let content: (ObservedObject<VL>) -> Content

    public init(_ listenable: VL, @ViewBuilder builder: @escaping (ObservedObject<VL>) -> Content) {
        _listenable = .init(wrappedValue: listenable)
        self.content = builder
    }

    public var body: some View {
        content(_listenable)
    }

}
