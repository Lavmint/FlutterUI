//
//  File.swift
//  
//
//  Created by Alexey Averkin on 04.11.2021.
//

import Foundation
import SwiftUI
import Combine

open class Bloc<State: Hashable, Event: Hashable>: ObservableObject {
    
    @Subject public var state: State
    
    private var _updates = Set<AnyCancellable>()
    
    public init(state: State) {
        _state = .init(wrappedValue: state)
    }
    
    open func dispatch(event: Event) {
        makeState(for: event, oldState: state)
            .sink { newState in
                self.state = newState
            }
            .store(in: &_updates)
    }
    
    open func makeState(for event: Event, oldState: State) -> AnyPublisher<State, Never> {
        return Just(state).eraseToAnyPublisher()
    }
    
    deinit {
        _updates.forEach({ sub in
            sub.cancel()
        })
    }
    
}
