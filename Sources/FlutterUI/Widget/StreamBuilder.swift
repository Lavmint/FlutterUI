//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import Combine
import SwiftUI

private struct _StreamBuilderState<T: Hashable> {
    var snapshot: AsyncSnapshot<T> = .nothing()
    var animation: Animation? = .default
    var stream: AnyPublisher<T, Error>? = nil
}

/// https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html
public struct StreamBuilder<T: Hashable, Content: View>: View {
    
    let initialData: T?
    let content: (AsyncSnapshot<T>) -> Content
    
    @State private var state = _StreamBuilderState<T>()
    
    public init(initialData: T? = nil, stream: AnyPublisher<T, Error>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.initialData = initialData
        self.content = buider
        state.snapshot = initial()
        state.stream = stream
        if state.stream  != nil {
            state.snapshot = afterConnected(state.snapshot)
        } else {
            state.snapshot = afterDisconnected(state.snapshot)
        }
    }
    
    public var body: some View {
        content(state.snapshot)
            .onReceive(getStream(state.snapshot)) { next in
                withAnimation(state.animation) {
                    state.snapshot = next
                }
            }
    }
    
    public func getStream(_ current: AsyncSnapshot<T>) -> AnyPublisher<AsyncSnapshot<T>, Never> {
        guard let stream = state.stream  else {
            return Empty().eraseToAnyPublisher()
        }
        return stream
            .map({ data -> AsyncSnapshot<T> in
                afterData(current, data: data)
            })
            .catch({ error -> AnyPublisher<AsyncSnapshot<T>, Never> in
                Just(afterError(current, error: error as NSError))
                    .eraseToAnyPublisher()
            })
            .receive(on: OperationQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func afterConnected(_ current: AsyncSnapshot<T>) -> AsyncSnapshot<T> {
        return current.inState(.waiting)
    }
    
    public func afterData(_ current: AsyncSnapshot<T>, data: T) -> AsyncSnapshot<T> {
        return .withData(.active, data: data)
    }
    
    public func afterDisconnected(_ current: AsyncSnapshot<T>) -> AsyncSnapshot<T> {
        return current.inState(.unknown)
    }
    
    public func afterError(_ current: AsyncSnapshot<T>, error: NSError) -> AsyncSnapshot<T> {
        return .withError(.active, error: error)
    }
    
    public func initial() -> AsyncSnapshot<T> {
        return initialData == nil ? .nothing() : .withData(.unknown, data: initialData!)
    }
    
    public func setAnimation(_ animation: Animation?) -> Self {
        let copy = self
        copy.state.animation = animation
        return copy
    }
    
    public func removeDuplicates() -> Self {
        let copy = self
        copy.state.stream = copy.state.stream?
            .removeDuplicates()
            .eraseToAnyPublisher()
        return copy
    }
    
}

public extension StreamBuilder {
    
    init(subject: CurrentValueSubject<T, Never>, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: subject.value,
            stream: subject.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init<S>(subject: CurrentValueSubject<S, Never>, keyPath: KeyPath<S, T>, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: subject.value[keyPath: keyPath],
            stream: subject.map(keyPath)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, stream: Published<T>.Publisher, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, stream: AnyPublisher<T, Never>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream?.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, stream: PassthroughSubject<T, Never>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream?.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
}
