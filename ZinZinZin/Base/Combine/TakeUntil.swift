//
//  TakeUntil.swift
//  CombineTakeUntil
//
//  Created by hsncr on 20.01.2021.
//

import Foundation
import Combine

/// Republishes elements until another publisher emits an element, completion or error out.
///
/// After the second publisher publishes an element or completes, the publisher returned by this method finishes.
///
/// - Parameter other: A second publisher.
/// - Returns: A publisher that republishes elements until the second publisher publishes an element, completion or error out.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    func take<P: Publisher>(until other: P) -> Publishers.TakeUntil<Self, P> {
        return Publishers.TakeUntil(upstream: self, until: other)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
    
    // Failure types must match to pass failure event from second publisher to downstream subscriber.
    struct TakeUntil<Source: Publisher, Other: Publisher>: Publisher where Other.Failure == Source.Failure {
        
        typealias Output = Source.Output
        
        typealias Failure = Source.Failure
        
        public let source: Source
        
        public let other: Other
        
        init(upstream: Source, until: Other) {
            self.source = upstream
            self.other = until
        }
        
        // pass subscription object to subscriber
        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            subscriber.receive(subscription: Subscription(subscriber: subscriber,
                                                          source: source,
                                                          until: other))
        }
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers.TakeUntil {
    
    // Subscription handles order of execution using lock and states. Also performs side effects outside of locks.
    class Subscription<Downstream: Subscriber>: Combine.Subscription where Output == Downstream.Input, Failure == Downstream.Failure {
        
        private struct DemandContainer {
            let downstream: Downstream
            let source: Source
            let until: Other
        }
        
        private struct DownstreamContainer {
            let downstream: Downstream
            let sink: DemandableSubscriber<Output, Failure>
            var remainingDemand: Subscribers.Demand
        }
        
        // initial state is waiting. after first demand it gets observing and later completed with respect to execution.
        private enum State {
            case waiting(DemandContainer)
            case observing(DownstreamContainer)
            case completed
        }
        
        private var state: State
        
        private var lock = NSRecursiveLock()
        
        private var sourceCancellable: AnyCancellable?
        
        private var untilCancellable: AnyCancellable?
        
        init(subscriber: Downstream, source: Source, until other: Other) {
            state = .waiting(.init(downstream: subscriber, source: source, until: other))
        }
        
        // configure demand. start source and other subscriptions if it is initial demand, otherwise request demand from source.
        func request(_ demand: Subscribers.Demand) {
            lock.synchronized {
                switch state {
                case .waiting(let initial):
                    
                    let sink = DemandableSubscriber<Output, Failure>(initialDemand: demand,
                                                                     receiveCompletion: { [unowned self] completion in
                                                                        self.receivedSource(completion)
                                                                     },
                                                                     receiveValue: { [unowned self] value in
                                                                        self.receivedSource(value)
                                                                     })
                    
                    let untilSink = DemandableSubscriber<Other.Output, Failure>(initialDemand: .max(1),
                                                                                receiveCompletion: { [unowned self] completion in
                                                                                    self.receiveUntil(completion)
                                                                                },
                                                                                receiveValue: { [unowned self] value in
                                                                                    self.receiveUntil(value)
                                                                                })
                    
                    state = .observing(.init(downstream: initial.downstream,
                                             sink: sink,
                                             remainingDemand: demand))
                    
                    
                    return {
                        
                        self.untilCancellable = AnyCancellable(untilSink)
                        
                        initial.until.subscribe(untilSink)
                        
                        // state may end up 'completed' by here. check again to continue execution to subscribe source publisher.
                        switch self.state {
                        case .waiting:
                            preconditionFailure("impossible.")
                        case .observing:
                            // continue to subscribe source publisher
                            break
                        case .completed: // execution is finished. no need to observe source publisher
                            return
                        }
                        
                        self.sourceCancellable = AnyCancellable(sink)
                        
                        initial.source.subscribe(sink)
                    }
                case .observing(var container):
                    // add up new demand requests
                    container.remainingDemand += demand
                    
                    state = .observing(container)
                    
                    // request demand from demandableSubscriber
                    return { container.sink.requestDemand(demand) }
                case .completed:
                    break
                }
                
                return {}
            }
        }
        
        // received value from source publisher, handle it
        private func receivedSource(_ value: Output) {
            lock.synchronized {
                
                if case var .observing(container) = state {
                    
                    // if demands are still incomplete, pass value to downstream subscriber. otherwise ignore
                    if container.remainingDemand > .none {
                        let additional = container.downstream.receive(value)
                        container.remainingDemand += additional
                        container.remainingDemand -= 1
                        
                        if additional > .none {
                            
                            state = .observing(container)
                            
                            return { container.sink.requestDemand(additional) }
                        }
                        
                    }
                    
                    
                    state = .observing(container)
                    
                }
                
                return {}
            }
        }
        
        // Received completion from source publisher, cancel other publisher and send completion event.
        private func receivedSource(_ completion: Subscribers.Completion<Failure>) {
            lock.synchronized {
                
                if case let .observing(container) = state {
                    
                    state = .completed
                    
                    let untilCancellable = self.untilCancellable
                    self.untilCancellable = nil
                    
                    return {
                        untilCancellable?.cancel()
                        container.downstream.receive(completion: completion)
                    }
                }
                
                return {}
            }
        }
        
        // Received value from other publisher, cancel both publishers and send completion event.
        private func receiveUntil(_ value: Other.Output) {
            lock.synchronized {
                if case let .observing(container) = state {
                    
                    let sourceCancellable = self.sourceCancellable
                    let untilCancellable = self.untilCancellable
                    self.sourceCancellable = nil
                    self.untilCancellable = nil
                    
                    state = .completed
                    
                    return {
                        untilCancellable?.cancel()
                        sourceCancellable?.cancel()
                        container.downstream.receive(completion: .finished)
                    }
                }
                
                return {}
            }
        }
        
        // Received completion from other publisher, cancel source publisher and send completion event.
        private func receiveUntil(_ completion: Subscribers.Completion<Other.Failure>) {
            lock.synchronized {
                
                if case let .observing(container) = state {
                    
                    let sourceCancellable = self.sourceCancellable
                    
                    state = .completed
                    
                    self.sourceCancellable = nil
                    
                    return {
                        sourceCancellable?.cancel()
                        container.downstream.receive(completion: completion)
                    }
                }
                
                return {}
            }
        }
        
        
        // Received cancellation, cancel both publishers.
        func cancel() {
            lock.synchronized {
                
                if case .completed = state {
                    return {}
                }
                
                let sourceCancellable = self.sourceCancellable
                let untilCancellable = self.untilCancellable
                
                self.sourceCancellable = nil
                self.untilCancellable = nil
                
                self.state = .completed
                
                return {
                    sourceCancellable?.cancel()
                    untilCancellable?.cancel()
                }
            }
        }
    }
}
