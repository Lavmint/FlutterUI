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

private struct _FutureBuilderConfiguration {
    var animation: Animation? = .default
}

/// https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
public struct FutureBuilder<T: Equatable, Content: View>: View {
    
    private let future: AnyPublisher<T, Error>
    private let initialData: T?
    private let content: (AsyncSnapshot<T>) -> Content
    private var config = _FutureBuilderConfiguration()
    
    @State private var snapshot: AsyncSnapshot<T> = .nothing()
    
    public init(future: AnyPublisher<T, Error>, initialData: T? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.future = future
        self.initialData = initialData
        self.content = buider
        if let data = initialData {
            snapshot = .withData(.nothing, data: data)
        }
    }
    
    public var body: some View {
        if snapshot.connectionState == .nothing {
            content(.waiting())
                .onReceive(_getFuture()) { snapshot in
                    withAnimation(config.animation) {
                        self.snapshot = snapshot
                    }
                }
        } else {
            content(snapshot)
        }
    }
    
    private func _getFuture() -> AnyPublisher<AsyncSnapshot<T>, Never> {
        return future
            .map({ data in
                AsyncSnapshot<T>.withData(.done, data: data)
            })
            .catch { error in
                Just(AsyncSnapshot<T>.withError(.done, error: error))
            }
            .receive(on: OperationQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func setAnimation(_ animation: Animation?) -> Self {
        var copy = self
        copy.config.animation = animation
        return copy
    }
    
}
