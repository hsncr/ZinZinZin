//
//  ComposeViewController.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit
import Combine

final class ComposeViewController: BaseViewController {
    
    let completed = PassthroughSubject<Bool, Never>()
    
    let present = PassthroughSubject<Void, Never>()
    
    private var bag = Set<AnyCancellable>()
    
    private let tab: Tab
    
    public init(tab: Tab) {
        self.tab = tab
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var buttonContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, okButton])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 32
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, buttonContainerStackView, presentTestButton])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "You are about to create another \(tab.title). Are you sure?"
        label.font = UIFont.systemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [unowned self] _ in
            self.completed.send(true)
        }))
        button.contentHorizontalAlignment = .center
        button.setTitle("OK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [unowned self] _ in
            self.completed.send(false)
        }))
        button.contentHorizontalAlignment = .center
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        return button
    }()
    
    
    private lazy var presentTestButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [unowned self] _ in
            self.present.send(())
        }))
        button.contentHorizontalAlignment = .center
        button.setTitle("Present Test", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        view.backgroundColor = .white
        
        stackView.addConstraints(equalToSuperview(with: .init(top: 64,
                                                              left: 32,
                                                              bottom: -64,
                                                              right: -32)))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = tab.title
    }
}
