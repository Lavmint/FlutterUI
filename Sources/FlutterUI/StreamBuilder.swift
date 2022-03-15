//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import Combine
import SwiftUI
import FlutterCore

private struct _StreamBuilderConfiguration<T> {
    var animation: Animation? = .default
    var stream: AnyPublisher<T, Error>? = nil
}

/// https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html
public struct StreamBuilder<T: Equatable, Content: View>: View {
    
    public let initialData: T?
    public let content: (AsyncSnapshot<T>) -> Content
    private var config = _StreamBuilderConfiguration<T>()
    
    @State public var snapshot: AsyncSnapshot<T> = .nothing()
    
    public init(initialData: T? = nil, stream: AnyPublisher<T, Error>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.initialData = initialData
        self.content = buider
        self.snapshot = initial()
        self.config.stream = stream
        if config.stream != nil {
            snapshot = afterConnected(snapshot)
        } else {
            snapshot = afterDisconnected(snapshot)
        }
    }
    
    public var body: some View {
        content(snapshot)
            .onReceive(getStream(snapshot)) { next in
                withAnimation(config.animation) {
                    snapshot = next
                }
            }
    }
    
    public func getStream(_ current: AsyncSnapshot<T>) -> AnyPublisher<AsyncSnapshot<T>, Never> {
        guard let stream = config.stream  else {
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
        return current.inState(.nothing)
    }
    
    public func afterError(_ current: AsyncSnapshot<T>, error: NSError) -> AsyncSnapshot<T> {
        return .withError(.active, error: error)
    }
    
    public func initial() -> AsyncSnapshot<T> {
        return initialData == nil ? .nothing() : .withData(.nothing, data: initialData!)
    }
    
    public func setAnimation(_ animation: Animation?) -> Self {
        var copy = self
        copy.config.animation = animation
        return copy
    }
    
    public func removeDuplicates() -> Self {
        var copy = self
        copy.config.stream = config.stream?
            .removeDuplicates()
            .eraseToAnyPublisher()
        return copy
    }
    
}

public extension StreamBuilder {
    
    init(_ subject: CurrentValueSubject<T, Never>, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: subject.value,
            stream: subject.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init<S>(_ subject: CurrentValueSubject<S, Never>, _ keyPath: KeyPath<S, T>, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: subject.value[keyPath: keyPath],
            stream: subject.map(keyPath)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, _ stream: Published<T>.Publisher, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, _ stream: AnyPublisher<T, Never>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream?.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
    init(initialData: T? = nil, _ stream: PassthroughSubject<T, Never>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.init(
            initialData: initialData,
            stream: stream?.setFailureType(to: Error.self).eraseToAnyPublisher(),
            buider: buider
        )
    }
    
}

/// https://api.flutter.dev/flutter/dart-async/StreamView-class.html
public extension StreamBuilder {
    
    static func viewer<S: Equatable, T: Equatable, C: View>(_ subject: CurrentValueSubject<S, Never>, _ keyPath: KeyPath<S, T>, @ViewBuilder content: @escaping (T) -> C) -> StreamBuilder<T, C>  {
        StreamBuilder<T, C>(subject, keyPath) { snapshot in
            content(snapshot.data!)
        }
    }
    
    static func viewer<T: Equatable, C: View>(_ subject: CurrentValueSubject<T, Never>, @ViewBuilder content: @escaping (T) -> C) -> StreamBuilder<T, C>  {
        StreamBuilder<T, C>(subject) { snapshot in
            content(snapshot.data!)
        }
    }
    
    static func viewer<C: View>(initialData: T? = nil, stream: Published<T>.Publisher, @ViewBuilder content: @escaping (T?) -> C) -> StreamBuilder<T, C>  {
        StreamBuilder<T, C>(initialData: initialData, stream) { snapshot in
            content(snapshot.data)
        }
    }
    
    static func viewer<C: View>(initialData: T? = nil, stream: AnyPublisher<T, Never>? = nil, @ViewBuilder content: @escaping (T?) -> C) -> StreamBuilder<T, C>  {
        StreamBuilder<T, C>(initialData: initialData, stream) { snapshot in
            content(snapshot.data)
        }
    }
    
    static func viewer<C: View>(initialData: T? = nil, stream: PassthroughSubject<T, Never>? = nil, @ViewBuilder content: @escaping (T?) -> C) -> StreamBuilder<T, C>  {
        StreamBuilder<T, C>(initialData: initialData, stream) { snapshot in
            content(snapshot.data)
        }
    }
    
}
