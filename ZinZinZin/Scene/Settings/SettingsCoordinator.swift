//
//  SettingsCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit
import Combine

enum SettingsCoordinationResult {
    case loggedOut
}

final class SettingsCoordinator: BaseCoordinator<SettingsCoordinationResult> {
    
    lazy var viewController: SettingsViewController = {
        let viewController = SettingsViewController()
        return viewController
    }()
    
    override var source: UIViewController  {
        get { viewController }
        set {}
    }
    
    override func start() -> AnyPublisher<SettingsCoordinationResult, Never> {
        
        let pushLogoutResult = viewController.pushSubject
            .flatMap { _ in
                self.push(to: SettingsCoordinator(presenting: self.router.navigationController))
            }
            .filter { $0 == .loggedOut }
        
        let logoutAction = viewController.logoutSubject.map { _ in SettingsCoordinationResult.loggedOut }
            
        
        viewController.presentSubject
            .flatMap { [unowned self] _ in
                self.present(to: ComposeCoordinator(presenting: NavigationController(), tab: .waking))
            }
            .sink { result in
                //
            }
            .store(in: &bag)
        
        return Publishers.Merge(logoutAction, pushLogoutResult)
            .eraseToAnyPublisher()
    }
}
