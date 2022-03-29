//
//  NavigationController.swift
//  BasicCoordinator
//
//  Created by hsncr on 20.12.2020.
//

import UIKit

public class NavigationController: UINavigationController {
    
    var releaseClosures: [String: ReleaseClosure] = [:]
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Release Handler
extension NavigationController: ReleaseHandler {
    public var keys: [String] {
        Array(releaseClosures.keys)
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController,
                                     animated: Bool) {
        let popedKeys = detectPopedController(on: navigationController)
        completeRelease(for: popedKeys)
    }
    
    public func configureRelease(for viewController: UIViewController,
                          using completion: @escaping ReleaseClosure) {
        releaseClosures.updateValue(completion, forKey: viewController.description)
    }
    
    public func configurePopRelease(for viewController: UIViewController,
                          using completion: @escaping ReleaseClosure) {
        releaseClosures.updateValue(completion, forKey: "\(viewController.description).pop")
    }
    
    public func completeRelease(for viewController: UIViewController) {
        
        
    }
    
    public func completeRelease(for keys: [String]) {
        for key in keys {
            guard let completion = releaseClosures.removeValue(forKey: key) else {
                return
            }
            
            // if pop entry is created then it is manually poped or dismissed
            // so we must remove 'completion' handler without trigerring
            // and just call popCompletion to indicate animation is completed
            if let popCompletion = releaseClosures.removeValue(forKey: "\(key).pop") {
                popCompletion()
                return
            }
            
            completion()
        }
    }
    
    public func removeRelease(for viewController: UIViewController) {
        releaseClosures.removeValue(forKey: viewController.description)
    }
    
}

// MARK: Status Bar
extension NavigationController {
    
    public override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    public override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
}
