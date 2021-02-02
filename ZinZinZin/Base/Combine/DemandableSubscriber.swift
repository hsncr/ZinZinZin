//
//  ThreadSafeSubscriber.swift
//  CombineTakeUntil
//
//  Created by hsncr on 20.01.2021.

import Foundation
import Combine


public extension Publisher {
    
    func subscribe(with initialDemand: Subscribers.Demand = .unlimited,
                   receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
                   receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        let sink = DemandableSubscriber<Output, Failure>(initialDemand: initialDemand,
                                                         receiveCompletion: receiveCompletion,
                                                         receiveValue: receiveValue)
        subscribe(sink)
        return AnyCancellable(sink)
    }
}


///  DemandableSubscriber manages subscription state to handle events. It starts subscription with initialDemand, also it is able to receive demand requests and pass them to tied subscription.
public class DemandableSubscriber<Input, Failure: Error>: Subscriber, Cancellable {
    
    enum State {
        case unsubscribed
        case subscribed(Subscription)
        case completed
    }
    
    private var state: State = .unsubscribed
    private let initialDemand: Subscribers.Demand
    private let value: (Input) -> Void
    private let completion: (Subscribers.Completion<Failure>) -> Void
    private let lock = NSRecursiveLock()
    
    public init(initialDemand: Subscribers.Demand = .unlimited,
                receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
                receiveValue: @escaping ((Input) -> Void)) {
        self.initialDemand = initialDemand
        value = receiveValue
        completion = receiveCompletion
    }
    
    // MARK: requested demand is passed through subscription if it is subscribed state
    public func requestDemand(_ demand: Subscribers.Demand) {
        lock.synchronized {
            if case let .subscribed(subscription) = state {
                return { subscription.request(demand) }
            }
            
            return {}
        }
    }
    
    // MARK: Setup initial subscription demand or cancel received subscription if cancellation was already called
    public func receive(subscription: Subscription) {
        lock.synchronized {
            if case .unsubscribed = state {
                
                self.state = .subscribed(subscription)
                
                return {
                    if self.initialDemand != .none {
                        subscription.request(self.initialDemand)
                    }
                }
            } else { // subscriber is cancelled before receiving subscription, cancel it upon receiving
                return { subscription.cancel() }
            }
        }
    }
    
    // MARK: send values if state is subscribed, otherwise ignore
    public func receive(_ input: Input) -> Subscribers.Demand {
        lock.synchronized {
            if case .subscribed = state {
                return { self.value(input) }
            }
            
            return {}
        }
        
        return .none
    }
    
    // MARK: call completion block if state is subscribed, otherwise ignore
    public func receive(completion c: Subscribers.Completion<Failure>) {
        lock.synchronized {
            
            if case .subscribed(_) = state {
                state = .completed
                return { self.completion(c) }
            }
            
            return {}
        }
    }
    
    // MARK: call cancellation on subscription if state is subscribed, otherwise ignore
    public func cancel() {
        lock.synchronized {
            var subscription: Subscription?
            
            if case .subscribed(let s) = state {
                subscription = s
            }
            
            state = .completed
            
            return {
                subscription?.cancel()
            }
        }
    }
}
