//
//  CreateCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit
import Combine

final class ComposeCoordinator: BaseCoordinator<Bool> {
    
    private let tab: Tab
    
    private lazy var viewController: ComposeViewController = {
        let viewController = ComposeViewController(tab: tab)
        return viewController
    }()
    
    override var source: UIViewController  {
        get {
            router.navigationController.viewControllers = [viewController]
            return router.navigationController
        }
        set {}
    }
    
    init(presenting navigationController: NavigationController, tab: Tab) {
        self.tab = tab
        super.init(parent: navigationController)
        self.source = viewController
    }
    
    override func start() -> AnyPublisher<Bool, Never> {
        
        let dismiss = viewController.completed
        
        let multiplePresentResult = viewController.present
            .eraseToAnyPublisher()
            .flatMap { _ -> AnyPublisher<Bool, Never> in
                let coordinator = ComposeCoordinator(presenting: NavigationController(),
                                                     tab: self.tab)
                return self.present(to: coordinator)
            }.filter { $0 == true }
        
        return Publishers.Merge(dismiss, multiplePresentResult)
            .eraseToAnyPublisher()
    }
}


