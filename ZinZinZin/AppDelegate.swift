//
//  AppDelegate.swift
//  ZinZinZin
//
//  Created by hsncr on 23.12.2020.
//

import UIKit
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func performAsyncActionAsFuture() -> Publishers.Coordinate<Void> {
        return Publishers.Coordinate<Void> { subscriber -> Cancellable in
            DispatchQueue.main.asyncAfter(deadline:.now() + 10) {
                subscriber.send(completion: .finished)
            }
            
            return AnyCancellable{}
        }
    }

    var bag = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//
////        let completer = PassthroughSubject<Int, Never>()
//////        let completer = Empty<Void, Never>().delay(for: 0.9, scheduler: RunLoop.main)
//////        let completer = (0...4).publisher.delay(for: 0.1, scheduler: RunLoop.main)
////
//////      let publisher = CurrentValueSubject<Bool, Never>(true)
////        let publisher = (0...4000).publisher
////            .subscribe(on: DispatchQueue.global())
//////
////        publisher.prefix(untilCompleteFrom: completer)
////            .print("Complete From")
////            .sink { _ in }
////            .store(in: &bag)
//////
////        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
////            completer.send(1)
////        }
//        CombineText().perform()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

