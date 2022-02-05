//
//  File.swift
//  
//
//  Created by Alexey Averkin on 05.02.2022.
//

import Foundation

public struct AsyncSnapshot<T: Hashable>: Hashable {
    
    public let connectionState: ConnectionState
    public let data: T?
    public let error: NSError?
    
    public var hasData: Bool {
        return data != nil
    }
    
    public var hasError: Bool {
        return error != nil
    }
    
    public func requireData() throws -> T {
        if hasData {
            return data!
        }
        if hasError {
            throw error!
        }
        throw StateError("Snapshot has neither data nor error")
    }
    
    public func inState(_ state: ConnectionState) -> AsyncSnapshot<T> {
        return .init(connectionState: state, data: data, error: error)
    }
    
    private init(connectionState: ConnectionState, data: T?, error: NSError?) {
        self.connectionState = connectionState
        self.data = data
        self.error = error
    }
    
}

public extension AsyncSnapshot {
    
    static func nothing() -> AsyncSnapshot<T> {
        return .init(connectionState: .unknown, data: nil, error: nil)
    }
    
    static func waiting() -> AsyncSnapshot<T> {
        return .init(connectionState: .waiting, data: nil, error: nil)
    }
    
    static func withData(_ state: ConnectionState, data: T) -> AsyncSnapshot<T> {
        return .init(connectionState: state, data: data, error: nil)
    }
    
    static func withError(_ state: ConnectionState, error: Error) -> AsyncSnapshot<T> {
        return .init(connectionState: state, data: nil, error: error as NSError)
    }
}
