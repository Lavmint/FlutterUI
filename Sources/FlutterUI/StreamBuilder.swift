//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation
import Combine
import SwiftUI

public struct StreamBuilder<T: Hashable, Content: View>: View {
    
    let initialData: T?
    let stream: AnyPublisher<T, Error>?
    let content: (AsyncSnapshot<T>) -> Content
    
    @State var snapshot: AsyncSnapshot<T> = .nothing()
    
    public init(initialData: T? = nil, stream: AnyPublisher<T, Error>? = nil, @ViewBuilder buider: @escaping (AsyncSnapshot<T>) -> Content) {
        self.initialData = initialData
        self.stream = stream
        self.content = buider
        self.snapshot = initial()
        if stream != nil {
            self.snapshot = afterConnected(snapshot)
        } else {
            self.snapshot = afterDisconnected(snapshot)
        }
    }
    
    public var body: some View {
        content(snapshot)
            .onReceive(getStream(snapshot)) { next in
                withAnimation {
                    self.snapshot = next
                }
            }
    }
    
    public func getStream(_ current: AsyncSnapshot<T>) -> AnyPublisher<AsyncSnapshot<T>, Never> {
        guard let stream = stream else {
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
    
}
