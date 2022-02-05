//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import Combine
import SwiftUI

private struct _FutureBuilderState<T: Hashable> {
    var snapshot: AsyncSnapshot<T> = .nothing()
    var animation: Animation? = .default
}

public struct FutureBuilder<T: Hashable, Content: View>: View {
    
    let future: AnyPublisher<T, Error>
    let initialData: T?
    let content: (AsyncSnapshot<T>) -> Content
    
    @State private var state = _FutureBuilderState<T>()
    
    public init(future: AnyPublisher<T, Error>, initialData: T? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.future = future
        self.initialData = initialData
        self.content = buider
        if let data = initialData {
            state.snapshot = .withData(.unknown, data: data)
        }
    }
    
    public var body: some View {
        if state.snapshot.connectionState == .unknown {
            content(.waiting())
                .onReceive(_getFuture()) { snapshot in
                    withAnimation(state.animation) {
                        state.snapshot = snapshot
                    }
                }
        } else {
            content(state.snapshot)
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
}
