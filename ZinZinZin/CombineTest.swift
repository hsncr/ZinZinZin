//
//  CombineTest.swift
//  ZinZinZin
//
//  Created by hsncr on 31.12.2020.
//

import Foundation
import Combine
//
//struct CombineText {
//    var bag = Set<AnyCancellable>()
//    
//    func perform() {
//        
//        let subject = PassthroughSubject<Int, Never>()
//
//        let publisher = Publishers.TakeUntil().print("TakeUntil")
//            
//        publisher.subscribe(on: DispatchQueue.global()).sink { _ in
//            //
//        }.store(in: &bag)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            bag.forEach { $0.cancel() }
//            bag.removeAll()
//        }
//
//    }
//}
//
//extension Publishers {
//    
//    struct TakeUntil: Publisher {
//        
//        
//        typealias Output = Int
//        typealias Failure = Never
//        
//        
//        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
//            AsyncOperation().perform { input in
//                subscriber.receive(input)
//            } completion: {
//                subscriber.receive(completion: .finished)
//            }
//
//        }
//        
//    
//    }
//    
//}
//
//
//struct AsyncOperation {
//    
//    func perform(next: @escaping (Int) -> Void, completion: @escaping () -> Void) {
//        
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            next(1)
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//                next(2)
//                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//                        completion()
//                }
//            }
//        }
//        
//    }
//}
//
