//
//  BaseViewController.swift
//  BasicCoordinator
//
//  Created by hsncr on 20.12.2020.
//

import UIKit

open class BaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
}
