//
//  SplashCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit
import Combine

final class SplashCoordinator: BaseCoordinator<Void> {
    
    lazy var viewController = {
        return SplashViewController()
    }()
    
    override var source: UIViewController  {
        get { viewController }
        set {}
    }
    
    init() {
        super.init(parent: NavigationController())
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        return viewController.completedSubject
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
