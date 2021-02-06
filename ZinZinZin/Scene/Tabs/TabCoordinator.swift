//
//  TabCoordinator.swift
//  BasicCoordinator
//
//  Created by hsncr on 21.12.2020.
//

import UIKit
import Combine

enum Tab: CaseIterable {
    case malignant, grandiose, communal, covert, waking
    
    public var title: String {
        switch self {
        case .malignant: return "Malignant"
        case .grandiose: return "Grandiose"
        case .communal: return "Communal"
        case .covert: return "Covert"
        case .waking: return "Waking Up"
        }
    }
    
    public var description: String {
        switch self {
        case .malignant: return "Malignant narcissists are considered to be at the extreme end of the continuum of narcissism due to their cruelty and aggressiveness. They’re paranoid, immoral, and sadistic. They find pleasure in creating chaos and taking people down. These narcissists aren’t necessarily grandiose, extroverted, or neurotic, but are closely related to psychopathy, the dark triad, and anti-social personality disorder"
        case .grandiose: return "for years research mainly focused on the familiar — exhibitionistic narcissists who seek the limelight. These are the boastful grandiose narcissists who are public figures and are recognizable in films. They’re described in the Diagnostic Statistical Manual of Mental Disorders (DSM) under narcissistic personality disorder (NPD). \n\n We can all spot those charming, attention-seeking extraverts whose vanity and boldness are at times obnoxious and shameless. They’re self-absorbed, entitled, callous, exploitative, authoritarian, and aggressive. Some are physically abusive. These unempathetic, arrogant narcissists think highly of themselves, but spare no disdain for others."
        case .communal: return "communal narcissists; They value warmth, agreeableness, and relatedness. They see themselves and want to be seen by others as the most trustworthy and supportive person and try to achieve this through friendliness and kindness. They’re outgoing like the grandiose narcissist. However, whereas the grandiose narcissist wants to be seen as the smartest and most powerful, a communal narcissist wants to be seen as the most giving and helpful. Communal narcissists’ vain selflessness is no less selfish than that of a grandiose narcissist. They both share similar motives for grandiosity, esteem, entitlement, and power, although they each employ different behaviors to achieve them. When their hypocrisy is discovered, it’s a bigger fall."
        case .covert: return "Lesser known are vulnerable narcissists (also referred to as covert, closet, or introverted narcissists). Like their grandiose kin, they’re self-absorbed, entitled, exploitative, unempathetic, manipulative, and aggressive, but they fear criticism so much that they shy away from attention. Individuals of both types of narcissism often lack autonomy, have imposter syndrome, a weak sense of self, are self-alienated and unable to master their environment. However, vulnerable narcissists experience these things to a markedly greater extent."
        case .waking: return "Waking Up is a guide to understanding the mind, for the purpose of living a more balanced and fulfilling life. \n\nJoin Sam Harris—neuroscientist, philosopher, and New York Times best-selling author—as he explores the practice of meditation and examines the theory behind it."
        }
    }
}

final class TabCoordinator: BaseCoordinator<Void> {
    
    let tabs: [Tab]
    
    let tabbarController = UITabBarController()
    
    override var source: UIViewController  {
        get { tabbarController }
        set {}
    }
    
    init(presenting navigationController: NavigationControllerReleaseHandler, tabs: [Tab]) {
        self.tabs = tabs
        super.init(presenting: navigationController)
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        
        let coordinators = tabs.map(configure(tab:))
        
        let masters = coordinators.map { $0.source }
        
        let result = coordinators.map { coordinate(to: $0) }
    
        tabbarController.viewControllers = masters
        tabbarController.selectedIndex = masters.count - 1 
        
        return Publishers.MergeMany(result)
            .eraseToAnyPublisher()
    }
    
    private func configure(tab: Tab) -> BaseCoordinator<Void> {
        switch tab {
        case .waking:
            return WakingUpCoordinator(presenting: NavigationController(), tab: tab)
        default:
            return LizardCoordinator(presenting: NavigationController(), tab: tab)
        }
    }
}
