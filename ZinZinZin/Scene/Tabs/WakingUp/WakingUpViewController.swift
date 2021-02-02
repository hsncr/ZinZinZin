//
//  WakingViewController.swift
//  BasicCoordinator
//
//  Created by hsncr on 22.12.2020.
//

import UIKit
import Combine

final class WakingUpViewController: BaseViewController {
    
    let openUrlSubject = PassthroughSubject<URL, Never>()
    
    let settingsSubject = PassthroughSubject<Bool, Never>()
    
    private var bag = Set<AnyCancellable>()
    
    private let tab: Tab
    
    public init(tab: Tab) {
        self.tab = tab
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var stackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var label: UIView = {
        let label = UILabel()
        label.textAlignment = .justified
        label.text = tab.description
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.4
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [unowned self] _ in
            if let url = URL(string: "https://wakingup.com/") {
                self.openUrlSubject.send(url)
            }
        }))
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitle("Join", for: .normal)
        return button
    }()
    
    private lazy var settingsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Settings",
                                     image: nil, primaryAction: UIAction(handler: { [unowned self] _ in
                                        self.settingsSubject.send(true)
                                     }))
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        view.backgroundColor = .white
        
        stackView.addConstraints(equalToSuperview(with: .init(top: 32,
                                                              left: 32,
                                                              bottom: -32,
                                                              right: -32)))
        
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = tab.title
    }
}
