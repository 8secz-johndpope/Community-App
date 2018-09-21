//
//  TextPostViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Alexandria

final class TextPostViewController: ViewController, StatusBarViewController {
    
    private let textPost: Contentful.TextPost
    
    var showStatusBarBackground = false {
        didSet {
            updateStatusBarBackground()
        }
    }
    
    let scrollView    = UIScrollView()
    let statusBarBackground = ShadowView()
    
    var additionalContainerOffset: CGFloat {
        return -50
    }
    
    private let imageView     = UIImageView()
    private let titleLabel    = UILabel()
    private let closeButton   = CloseButton()
    private let headerLabel   = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 20)
    private let containerView = UIView()
    private let textView      = SelfSizingTextView(frame: .zero)
    
    private var titleLabelConstraint: NSLayoutConstraint?
    
    required init(textPost: Contentful.TextPost) {
        self.textPost = textPost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.delegate = self
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        titleLabelConstraint?.constant = 100 + view.safeAreaInsets.top
        scrollView.scrollIndicatorInsets.top = 300
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .grayBlue
        
        statusBarBackground.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 50)
            $0.backgroundColor = .grayBlue
            $0.alpha = 0
        }
        
        scrollView.add(toSuperview: view, behind: statusBarBackground).customize {
            $0.constrainEdgesToSuperview()
            $0.alwaysBounceVertical = true
            $0.backgroundColor = .clear
            $0.panGestureRecognizer.addTarget(self, action: #selector(userDidPan))
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview(top: 300)
            $0.constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
        }
        
        titleLabel.add(toSuperview: scrollView).customize {
            $0.pinLeading(to: scrollView, plus: .padding).pinTrailing(to: scrollView, plus: -.padding)
            $0.constrainSize(toFit: .vertical)
            $0.font = .extraBold(size: 24)
            $0.textColor = .lightBackground
            $0.text = textPost.title
            $0.numberOfLines = 0
            $0.textAlignment = .center
            
            titleLabelConstraint = $0.constrainSafely(.centerY, to: scrollView, .top, plus: 100)
        }
        
        textView.add(toSuperview: containerView).customize {
            $0.constrainEdgesToSuperview()
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.backgroundColor = .lightBackground
            $0.isEditable = false
            $0.isSelectable = true
            $0.delegate = self
            $0.linkTextAttributes = [.foregroundColor : UIColor.orange]
            $0.attributedText = textPost.content.renderMarkdown
        }
        
        UIView(superview: containerView).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .lightBackground
        }
        
        closeButton.add(toSuperview: view).customize {
            $0.pinSafely(.top, to: view).pinTrailing(to: view)
            $0.constrainClose(height: 50)
            $0.tintColor = .lightBackground
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.dismiss(animated: true) }
        }
        
        headerLabel.add(toSuperview: statusBarBackground).customize {
            $0.pinLeading(to: statusBarBackground, plus: .padding).pinTrailing(to: statusBarBackground, plus: -58)
            $0.pinBottom(to: statusBarBackground).constrainHeight(to: 50)
            $0.font = .bold(size: 18)
            $0.textColor = .lightBackground
            $0.text = textPost.title
        }
    }
    
}

extension TextPostViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        
        check(containerView: containerView, in: self)
        titleLabel.transform = .translate(0, -scrollView.adjustedOffset.y * 0.6)
    }
    
}

extension TextPostViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        DeepLink.handle(url: URL)
        return false
    }
    
}
