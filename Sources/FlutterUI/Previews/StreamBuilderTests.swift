//
//  File.swift
//  
//
//  Created by Alexey Averkin on 04.11.2021.
//

import Foundation
import Combine
import SwiftUI

enum StreamBuilderTestEvent: Hashable {
    case foo
}

struct StreamBuilderTestState: Hashable {
    var counter: Int
}

class StreamBuilderTestBloc: Bloc<StreamBuilderTestState, StreamBuilderTestEvent> {
    
    init() {
        super.init(state: .init(counter: 0))
    }
    
    override func makeState(for event: StreamBuilderTestEvent, oldState: StreamBuilderTestState) -> AnyPublisher<StreamBuilderTestState, Never> {
        if event == .foo {
            return _onFoo(oldState: oldState)
        }
        fatalError()
    }
    
    private func _onFoo(oldState: StreamBuilderTestState) -> AnyPublisher<StreamBuilderTestState, Never> {
        let state = StreamBuilderTestState(counter: oldState.counter + 1)
        return Just(state).eraseToAnyPublisher()
    }
    
}

public struct StreamBuilderTestUI: View {
    
    @StateObject var bloc = StreamBuilderTestBloc()
    let timer = Timer.publish(every: 2.0, on: .main, in: .default)
    
    public init() {
        
    }
    
    public var body: some View {
        ZStack {
            SubjectStream(bloc.$state, keyPath: \.counter) { val in
                Text("\(val)")
                    .frame(width: 30, height: 30, alignment: .center)
                    .background(Color.blue)
            }
            .stream { st in
                st.removeDuplicates().eraseToAnyPublisher()
            }
        }
        .onReceive(timer.autoconnect()) { _ in
            bloc.dispatch(event: .foo)
        }
    }
}

struct StreamBuilderTestUI_Preview: PreviewProvider {
    
    static var previews: some View {
        StreamBuilderTestUI()
            .previewLayout(.device)
    }
}
