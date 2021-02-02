//
//  NarcoCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 22.12.2020.
//

import UIKit
import Combine


final class LizardCoordinator: BaseCoordinator<Void> {
    
    private let tab: Tab
    
    lazy var viewController = {
        return LizardViewController(tab: tab)
    }()
    
    override var source: UIViewController  {
        get { viewController }
        set {}
    }
    
    init(tab: Tab, parent navigationController: NavigationController) {
        
        self.tab = tab
        
        navigationController.tabBarItem = UITabBarItem(title: tab.title,
                                                       image: nil,
                                                       selectedImage: nil)
        
        super.init(parent: navigationController)
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        
        viewController.composeSubject
            .map { [unowned self] _ in self.tab }
            .flatMap { [unowned self] tab in
                self.startCompose(tab: tab)
            }.sink { [unowned self] result in
                if result == true {
                    self.viewController.numberOfItems += 1
                }
            }.store(in: &bag)
        
        return Publishers.Never()
            .eraseToAnyPublisher()
    }
    
    private func startCompose(tab: Tab) -> AnyPublisher<Bool, Never> {
        let coordinator = ComposeCoordinator(presenting: NavigationController(), tab: tab)
        return present(to: coordinator)
    }
}
