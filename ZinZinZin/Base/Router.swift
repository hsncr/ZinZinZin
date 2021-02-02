//
//  Router.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit

// MARK: Router
public class Router: NSObject, RouterProtocol {
    
    public let navigationController: NavigationController
    
    public init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
}

// MARK: RouterProtocol+UIAdaptivePresentationControllerDelegate
extension Router {
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let navigationController = presentationController.presentedViewController as? NavigationControllerReleaseHandler {
            navigationController.viewControllers.forEach { navigationController.completeRelease(for: $0) }
        } else {
            navigationController.completeRelease(for: presentationController.presentedViewController)
        }
    }
}

