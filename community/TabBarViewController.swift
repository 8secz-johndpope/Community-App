//
//  TabBarViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Alexandria

final class TabBarViewController: UITabBarController {
    
    private let tabBarView = TabBar(tabs: .table, .messages, .search, .settings)
    
    var tabs: [Tab] {
        return tabBarView.tabs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in tabBar.subviews where view !== tabBarView {
            view.alpha = 0
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func viewController(forTab tab: Tab) -> UIViewController? {
        guard let index = tabs.index(of: tab) else { return nil }
        return viewControllers?.at(index)
    }
    
    func move(to tab: Tab) {
        guard let controller = viewController(forTab: tab) else { return }
        
//        if controller === selectedViewController {
//            (controller as? ScrollsToTop)?.scrollToTop(animated: true)
//            return
//        }
        
        tabBarView.select(tab: tab)
        selectedViewController = controller
    }
    
}

extension TabBarViewController {
    
    private func setup() {
        
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = false
        tabBar.layer.borderWidth = 0
        tabBar.backgroundImage = UIImage(color: .clear)
        tabBar.isTranslucent = true
        
        viewControllers = tabBarView.tabs.map { $0.viewController }
        
        tabBarView.add(toSuperview: tabBar).customize {
            $0.constrainEdgesToSuperview()
            $0.didTap = { [weak self] tab in self?.move(to: tab) }
            $0.select(tab: .table)
        }
    }
    
}

extension TabBarViewController {
    
    enum Tab {
        case table
        case messages
        case search
        case settings
        
        var viewController: UIViewController {
            switch self {
            case .table:    return UINavigationController(rootViewController: HomeViewController())
            case .messages: return MessageListViewController()
            case .search:   return SearchViewController()
            case .settings: return SettingsViewController()
            }
        }
        
        var icon: Icon {
            switch self {
            case .table:    return .home
            case .messages: return .video
            case .search:   return .search
            case .settings: return .cog
            }
        }
    }
    
}

extension TabBarViewController {
    
    final class TabBar: ShadowView {
        
        let tabs: [Tab]
        
        private let container = UIView()
        private let stackView = UIStackView()
        
        var didTap: (Tab) -> Void = { _ in }
        
        private var items: [Item] = []
        
        required init(tabs: Tab...) {
            self.tabs = tabs
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            backgroundColor = .lightBackground
            
            shadowOffset = CGSize(width: 0, height: -10)
            shadowOpacity = 0.1
            
            container.add(toSuperview: self).customize {
                $0.pinLeading(to: self).pinTrailing(to: self)
                $0.pinTop(to: self).constrainHeight(to: 49)
                $0.backgroundColor = .lightBackground
            }
            
            stackView.add(toSuperview: container).customize {
                $0.constrainEdgesToSuperview()
                $0.alignment = .fill
                $0.axis = .horizontal
                $0.distribution = .fillEqually
                $0.spacing = 0
            }
            
            for tab in tabs {
                let item = Item(tab: tab).customize {
                    $0.add(toStackview: stackView)
                    $0.didTap = { [weak self] in self?.didTap(tab) }
                }
                
                if items.isEmpty {
                    item.isSelected = true
                }
                
                items.append(item)
            }
        }
        
        func select(tab: Tab) {
            items.forEach { $0.isSelected = ($0.tab == tab) }
        }
        
        private final class Item: UIView {
            let tab: Tab
            
            private let button = ItemButton()
            
            var didTap: () -> Void = {}
            
            var isSelected = false {
                didSet {
                    button.isSelected = isSelected
                }
            }
            
            required init(tab: Tab) {
                self.tab = tab
                super.init(frame: .zero)
                setup()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            func setup() {
                
                button.add(toSuperview: self).customize {
                    $0.constrainEdgesToSuperview()
                    $0.adjustsImageWhenHighlighted = false
                    $0.didTap = { [weak self] in self?.didTap() }
                    $0.configure(tab: tab)
                }
                
            }
        }
        
        private final class ItemButton: Button {
            
            override var isSelected: Bool {
                didSet {
                    iconView.font = isSelected ? .fontAwesome(.solid, size: 20) : .fontAwesome(.regular, size: 20)
                    iconView.textColor = isSelected ? .orange : .light
                }
            }
            
            private let iconView = UILabel()
            
            override func setup() {
                super.setup()
                
                clipsToBounds = false
                
                animationDuration = 0.4
                springDamping = 0.5
                
                backgroundView.customize {
                    $0.backgroundColor = .lightBackground
                    $0.shadowOpacity = 0
                }
                
                iconView.add(toSuperview: backgroundView).customize {
                    $0.pinLeading(to: backgroundView).pinTrailing(to: backgroundView)
                    $0.pinTop(to: backgroundView, plus: 10, atPriority: .required - 1).pinBottom(to: backgroundView, plus: -10, atPriority: .required - 1)
                    $0.textAlignment = .center
                    $0.font = .fontAwesome(.regular, size: 20)
                    $0.textColor = .light
                }
            }
            
            func configure(tab: Tab) {
                iconView.set(icon: tab.icon)
            }
            
        }
        
    }
    
}
