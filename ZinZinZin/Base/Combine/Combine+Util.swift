//
//  Combine+Util.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import Foundation
import Combine

public extension Publishers {
    
    struct Never<Output>: Publisher {
        
        public typealias Failure = Swift.Never
        
        let empty = Empty<Output, Failure>(completeImmediately: false)
        
        public init() {}
        
        public func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Output == S.Input {
            empty.receive(subscriber: subscriber)
        }
    }
    
    struct Coordinate<Output>: Publisher {
        
        public typealias SubscriberHandler = (Subscriber) -> Cancellable
        
        public typealias Failure = Swift.Never
        
        private let handler: SubscriberHandler
        
        public init(_ handler: @escaping SubscriberHandler) {
            self.handler = handler
        }
        
        public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure  {
            subscriber.receive(subscription: Subscription(handler: handler,
                                                          downstream: subscriber))
        }
    }
}

public extension Publishers.Coordinate {
    
    class Subscription<S: Combine.Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        
        private var cancelable: Cancellable?
        private var downstream: S
        
        init(handler: @escaping SubscriberHandler,
             downstream: S) {
            self.downstream = downstream
            let subscriber = Subscriber { [unowned self] in
                _ = self.downstream.receive($0)
            } onCompletion: { [weak self] in
                self?.downstream.receive(completion: $0)
            }
            
            self.cancelable = handler(subscriber)
        }
        
        public func request(_ demand: Subscribers.Demand) {
            //
        }
        
        public func cancel() {
            self.cancelable?.cancel()
            self.cancelable = nil
        }
    }
}


public extension Publishers.Coordinate {
    
    struct Subscriber {
        
        private let onValue: (Output) -> Void
        private let onCompletion: (Subscribers.Completion<Swift.Never>) -> Void
        
        fileprivate init(onValue: @escaping (Output) -> Void,
                         onCompletion: @escaping (Subscribers.Completion<Swift.Never>) -> Void) {
            self.onValue = onValue
            self.onCompletion = onCompletion
        }
        
        public func send(_ input: Output) {
            onValue(input)
        }
        
        public func send(completion: Subscribers.Completion<Swift.Never>) {
            onCompletion(completion)
        }
    }
    
}
