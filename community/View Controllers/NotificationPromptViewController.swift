//
//  NotificationPromptViewController.swift
//  community
//
//  Created by Jonathan Landon on 5/11/19.
//

import UIKit
import Diakoneo

final class NotificationPromptViewController: ViewController {
    
    private let holderView          = UIView()
    private let iconView            = UILabel()
    private let infoLabel           = UILabel()
    private let notificationsButton = UIButton()
    private let dismissButton       = UIButton()
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        notificationsButton.setBackgroundColor(.notificationsButton, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.alpha(0.8)
        
        holderView.add(toSuperview: view).customize {
            $0.pinLeading(to: view, plus: .padding * 2).pinTrailing(to: view, plus: -.padding * 2)
            $0.pinCenterY(to: view)
            $0.cornerRadius = 8
            $0.backgroundColor = .backgroundAlt
            $0.addGesture(type: .pan) { [weak self] in self?.onDrag(gesture: $0) }
        }
        
        infoLabel.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView, plus: .padding).pinTrailing(to: holderView, plus: -.padding)
            $0.pinTop(to: holderView, plus: 30).constrainSize(toFit: .vertical)
            $0.font = .karla(.regular, size: 20)
            $0.textColor = .text
            $0.text = "Find out when new content is available in the app."
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        iconView.add(toSuperview: holderView).customize {
            $0.pinCenterX(to: holderView).pinTop(to: infoLabel, .bottom, plus: 30)
            $0.constrainSize(toFit: .vertical, .horizontal)
            $0.font = .fontAwesome(.light, size: 80)
            $0.textColor = .text
            $0.set(icon: .bells)
        }
        
        notificationsButton.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView, plus: .padding).pinTrailing(to: holderView, plus: -.padding)
            $0.pinTop(to: iconView, .bottom, plus: 35).constrainHeight(to: 50)
            $0.setBackgroundColor(.notificationsButton, for: .normal)
            $0.setTitle("Enable Notifications", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .karla(.bold, size: 18)
            $0.cornerRadius = 4
            $0.addTarget(for: .touchUpInside) {
                NotificationManager.register { [weak self] isGranted in
                    print("Is granted: \(isGranted)")
                    self?.hide()
                }
            }
        }
        
        dismissButton.add(toSuperview: holderView).customize {
            $0.pinLeading(to: holderView, plus: .padding).pinTrailing(to: holderView, plus: -.padding)
            $0.pinTop(to: notificationsButton, .bottom, plus: 10).pinBottom(to: holderView, plus: -10)
            $0.constrainHeight(to: 40)
            $0.setTitle("No thanks", for: .normal)
            $0.setTitleColor(.text, for: .normal)
            $0.titleLabel?.font = .karla(.regular, size: 16)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.hide() }
        }
    }
    
    @objc private func onDrag(gesture: UIGestureRecognizer) {
        guard let gesture = gesture.pan else { return }
        
        let translation = gesture.translation(in: view)
        
        holderView.transform = .translate(0, translation.y * 0.85)
        
        if case .ended = gesture.state {
            if translation.y > 100 {
                hide()
            }
            else {
                reset(duration: 0.25)
            }
        }
    }
    
    private func reset(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            self.view.backgroundColor = UIColor.black.alpha(0.8)
            self.holderView.transform = .identity
        }, completion: nil)
    }
    
}

extension NotificationPromptViewController {
    
    func present() {
        let promptCount: Int = Storage.get(.notificationPromptDisplayCount) ?? 0
        
        defer { Storage.set(promptCount + 1, for: .notificationPromptDisplayCount) }
        
        guard promptCount.isMultiple(of: 5) else { return }
        
        view.backgroundColor = .clear
        holderView.transform = .translate(0, UIScreen.main.height)
        
        UIViewController.current?.present(self, animated: false) { self.reset() }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.33, animations: {
            self.view.backgroundColor = .clear
            self.holderView.transform = .translate(0, UIScreen.main.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
}
