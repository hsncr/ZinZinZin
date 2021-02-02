//
//  SafariCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 23.12.2020.
//

import Foundation
import SafariServices
import Combine

final class SafariCoordinator: BaseCoordinator<Void> {
    
    let url: URL
    
    let dismissSubject = PassthroughSubject<Void, Never>()
    
    private lazy var viewController = SFSafariViewController(url: url)
    
    override var source: UIViewController  {
        get { viewController }
        set {}
    }
    
    init(parent navigationController: NavigationController, url: URL) {
        self.url = url
        super.init(parent: navigationController)
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        
        viewController.delegate = self
        
        return dismissSubject
            .eraseToAnyPublisher()
    }
    
    
}

extension SafariCoordinator: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismissSubject.send(())
    }
}
