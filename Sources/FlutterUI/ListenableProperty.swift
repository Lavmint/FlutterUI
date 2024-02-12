//
//  File.swift
//  
//
//  Created by Alexey Averkin on 31.01.2024.
//

import Foundation
import SwiftUI

public struct ListenableProperty<O: ObservableObject, T: Equatable, V: View>: View {

    let object: O
    let keyPath: KeyPath<O, T>
    @ViewBuilder let content: (ObservedObject<O>) -> V

    public init(_ object: O, _ keyPath: KeyPath<O, T>, @ViewBuilder builder: @escaping (ObservedObject<O>) -> V) {
        self.object = object
        self.keyPath = keyPath
        self.content = builder
    }

    public var body: some View {
        ListenableObject(object) { obj in
            SingleContentView(
                value: obj.wrappedValue[keyPath: keyPath],
                object: obj,
                content: content
            )
            .toEquatable()
        }
    }

}

fileprivate struct SingleContentView<T: Equatable, V: View, O: ObservableObject>: View, Equatable {

    let value: T
    let object: ObservedObject<O>
    @ViewBuilder let content: (ObservedObject<O>) -> V

    var body: some View {
        content(object)
    }

    static func == (lhs: SingleContentView<T, V, O>, rhs: SingleContentView<T, V, O>) -> Bool {
        return lhs.value == rhs.value
    }

    func toEquatable() -> EquatableView<Self> {
        return EquatableView(content: self)
    }

}
