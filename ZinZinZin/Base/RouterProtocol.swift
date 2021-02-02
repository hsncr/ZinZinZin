//
//  Router.swift
//  BasicCoordinator
//
//  Created by hsncr on 20.12.2020.
//

import Foundation
import UIKit
import Combine

public typealias NavigationControllerReleaseHandler = UINavigationController & ReleaseHandler

// MARK: Router Protocol
public protocol RouterProtocol: UIAdaptivePresentationControllerDelegate {
    
    associatedtype T: NavigationControllerReleaseHandler
    
    var navigationController: T { get }
    
    /// pushes source view controller into navigation stack
    /// and sends completion when poped via back button or swipe gesture
    func push(_ routable: RoutableProtocol,
              animated: Bool) -> Publishers.Coordinate<Void>
    
    /// present source view controller into navigation stack
    /// and sends completion when dismissed via iOS 13 dismiss gesture
    func present(_ routable: RoutableProtocol,
                 animated: Bool) -> Publishers.Coordinate<Void>
    
    /// calls pop on navigation controller
    /// and sends completion when pop animation is completed
    /// removes release closure that is bound to source due to manual execution.
    func pop(_ routable: RoutableProtocol,
             animated: Bool) -> Publishers.Coordinate<Void>
    
    /// calls dismiss on source view controller
    /// and sends completion when dismiss is completed.
    /// removes release closure that is bound to source due to manual execution.
    func dismiss<C: Coordinator, U>(_ routable: C,
                                    animated: Bool) -> AnyPublisher<U, Never> where U == C.CoordinationResult
    
    /// execute release closures of previous navigation controller contents to release coordinators
    /// and calls setViewController method using source.
    func setViewController(_ routable: RoutableProtocol,
                           animated: Bool)
    
    /// changes root view controller using source
    func setRootViewController(_ routable: RoutableProtocol,
                               into window: UIWindow,
                               animated: Bool)
    
    /// changes root view controller using navigation controller property
    func setAsRoot(into window: UIWindow)
    
}

//
// MARK: Default-Rx Implementation
extension RouterProtocol {
    
    public func push(_ routable: RoutableProtocol,
                     animated: Bool) -> Publishers.Coordinate<Void> {
        
        return Publishers.Coordinate<Void> { [unowned self] subscriber -> Cancellable in
            
            self.push(routable.source, animated: animated) {
                subscriber.send(completion: .finished)
            }
            
            return AnyCancellable {}
        }
    }
    
    public func pop(_ routable: RoutableProtocol, animated: Bool = true) -> Publishers.Coordinate<Void> {
        return Publishers.Coordinate<Void> { [unowned self] subscriber -> Cancellable in
            
            self.pop(routable.source) {
                subscriber.send(completion: .finished)
            }
            
            return AnyCancellable {}
        }
    }
    
    public func present(_ routable: RoutableProtocol,
                        animated: Bool) -> Publishers.Coordinate<Void> {
        
        return Publishers.Coordinate<Void> { [unowned self] subscriber -> Cancellable in
            
            self.present(routable.source, animated: animated) {
                subscriber.send(completion: .finished)
            }
            
            return AnyCancellable {}
        }
    }
    
    public func dismiss<C: Coordinator, U>(_ routable: C,
                                           animated: Bool = true) -> AnyPublisher<U, Never> where U == C.CoordinationResult {
        
        return Publishers.Coordinate<U> { [unowned self] subscriber -> Cancellable in
            
            routable.source.dismiss(animated: animated) {
                if let navigationController = routable.source as? NavigationControllerReleaseHandler {
                    navigationController.viewControllers.forEach {
                        navigationController.removeRelease(for: $0)
                    }
                } else {
                    self.navigationController.removeRelease(for: routable.source)
                }
                
                subscriber.send(completion: .finished)
            }
            
            return AnyCancellable {}
        }.eraseToAnyPublisher()
    }
    
    public func popToRoot(animated: Bool = true) {
        
        guard let viewControllers = navigationController.popToRootViewController(animated: animated) else {
            return
        }

        viewControllers.forEach { navigationController.completeRelease(for: $0) }
    }
    
    /// calls completion on previous content of navigationController
    /// and update navigation controller with routable
    public func setViewController(_ routable: RoutableProtocol,
                                  animated: Bool) {
        
        if navigationController.viewControllers.isEmpty == false {
            let previousViewControllers = self.navigationController.viewControllers
            previousViewControllers.forEach { navigationController.completeRelease(for: $0) }
        }
        
        navigationController.setViewControllers([routable.source],
                                                animated: animated)
    }
    
    /// set root view controller
    public func setRootViewController(_ routable: RoutableProtocol,
                                      into window: UIWindow,
                                      animated: Bool = true) {
        window.rootViewController = routable.source
        window.makeKeyAndVisible()
        
        guard animated else {
            return
        }

        UIView.transition(with: window,
                          duration: 0.8,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    public func setAsRoot(into window: UIWindow) {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    
        UIView.transition(with: window,
                          duration: 0.8,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

// MARK: Default-Helper Impl
extension RouterProtocol {
    
    // helper function that configure release closure and execute push.
    // release closure is called on back button or swipe back gesture
    private func push(_ viewController: UIViewController,
                      animated: Bool = true,
                      using completion: @escaping ReleaseClosure) {
        
        navigationController.configureRelease(for: viewController,
                                              using: completion)
        
        navigationController.pushViewController(viewController,
                                                animated: animated)
    }
    
    // helper function that configure pop release closure and execute pop.
    // release closure is called by navigation controller when animation is completed
    private func pop(_ viewController: UIViewController,
                      animated: Bool = true,
                      using completion: @escaping ReleaseClosure) {
        
        navigationController.configurePopRelease(for: viewController,
                                       using: completion)
        
        navigationController.popViewController(animated: animated)
    }
    
    
    /// if presented view controller is navigation controller then set release closures on it,
    /// otherwise navigationController property is used
    private func present(_ viewController: UIViewController,
                         animated: Bool = true,
                         using completion: @escaping ReleaseClosure) {
        
        if let navigationController = viewController as? NavigationControllerReleaseHandler {
            navigationController.viewControllers.forEach {
                navigationController.configureRelease(for: $0,
                                                      using: completion)
            }
        } else if viewController is UINavigationController {
            fatalError("Presenting navigation controller must implement ReleaseHandler." +
                        "Because routing operations will be handled by it after presentation.")
        } else {
            navigationController.configureRelease(for: viewController,
                                                  using: completion)
        }
        
        navigationController.present(viewController,
                                     animated: animated) {
            viewController.presentationController?.delegate = self
        }
    }
}

