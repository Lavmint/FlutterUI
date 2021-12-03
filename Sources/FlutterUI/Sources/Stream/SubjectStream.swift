//
//  File.swift
//  
//
//  Created by Alexey Averkin on 03.11.2021.
//

import Foundation
import Combine
import SwiftUI

private struct _StreamBuilderState<Value> {
    var value: Value
    var stream: AnyPublisher<Value, Never>
    var animation: Animation? = nil
}

public struct SubjectStream<Root, Output, Content: View>: View {

    @State private var state: _StreamBuilderState<Output>
    private let content: Builder
    
    public typealias Subject = CurrentValueSubject<Root, Never>
    public typealias Path = KeyPath<Root, Output>
    public typealias Builder = (Output) -> Content
    public typealias Stream = AnyPublisher<Output, Never>
    
    public init(_ subject: Subject, keyPath: Path, @ViewBuilder builder: @escaping Builder) {
        let stream = subject.map(keyPath).eraseToAnyPublisher()
        let value = subject.value[keyPath: keyPath]
        _state = .init(wrappedValue: _StreamBuilderState.init(value: value, stream: stream))
        content = builder
    }
    
    public var body: some View {
        content(state.value)
            .onReceive(state.stream.receive(on: OperationQueue.main), perform: { newValue in
                withAnimation(state.animation) {
                    state.value = newValue
                }
            })
    }
    
    public func animation(_ animation: Animation?) -> Self {
        state.animation = animation
        return self
    }
    
    public func stream(_ modify: (Stream) -> Stream) -> Self {
        state.stream = modify(state.stream)
        return self
    }
    
}
