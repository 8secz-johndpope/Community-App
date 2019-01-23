//
//  ContentViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Alexandria

final class ContentViewController: ViewController, StatusBarViewController {
    
    enum Content {
        case message(Watermark.Message)
        case textPost(Contentful.TextPost)
        
        var title: String {
            switch self {
            case .message(let message): return message.title
            case .textPost(let post):   return post.title
            }
        }
        
        var isMessage: Bool {
            if case .message = self {
                return true
            }
            return false
        }
        
        var isTextPost: Bool {
            if case .textPost = self {
                return true
            }
            return false
        }
    }
    
    let content: Content
    
    var showStatusBarBackground = false {
        didSet {
            updateStatusBarBackground()
            
            if showStatusBarBackground, case .message = content {
                closeButton.configure(normal: .dark, highlighted: .black)
            }
            else {
                closeButton.configure(normal: .lightBackground, highlighted: .lightest)
            }
            
            closeButton.alpha = buttonAlpha
        }
    }
    
    override var pullToDismissOffset: CGFloat {
        return 80
    }
    
    let scrollView          = UIScrollView()
    let statusBarBackground = ShadowView()
    
    private let containerView: ContentContainerView
    
    private let statusBarCover = UIView()
    private let headerView     = ContentHeaderView()
    private let closeButton    = CloseButton()
    private let titleLabel     = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 20)
    
    private var isLandscape = false
    private var scrollAlpha: CGFloat = 1
    
    private var buttonAlpha: CGFloat {
        if showStatusBarBackground || headerView.isShowingControls {
            return 1
        }
        else {
            return 0
        }
    }
    
    private var videoConstraint = NSLayoutConstraint()
    private var controlsObserver: NSKeyValueObservation?
    
    required init(content: Content) {
        self.content = content
        self.containerView = ContentContainerView(content: content)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(message: Watermark.Message) {
        self.init(content: .message(message))
    }
    
    convenience init(textPost: Contentful.TextPost) {
        self.init(content: .textPost(textPost))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.delegate = self
        headerView.configureBackgroundAudio(isEnabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        containerView.resetProgressButton()
    }
    
    var headerTapGesture: UIGestureRecognizer?
    var headerDoubleTapGesture: UIGestureRecognizer?
    
    override func setup() {
        
        view.backgroundColor = .clear
        view.clipsToBounds = true
        
        scrollView.add(toSuperview: view)
        headerView.add(toSuperview: scrollView)
        containerView.add(toSuperview: scrollView)
        
        headerView.customize {
            $0.pinTop(to: view).pinBottom(to: containerView, .top, plus: 50, atPriority: .required - 1)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.configure(content: content)
            $0.delegate = self
            
            videoConstraint = $0.constrain(.bottom, to: view, .bottom, atPriority: .required - 1)
            videoConstraint.isActive = false
        }
        
        controlsObserver = headerView.observe(\.isShowingControls, options: .new) { [weak self] headerView, change in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
                self.closeButton.alpha = self.buttonAlpha
            }
        }
        
        scrollView.customize {
            $0.constrainEdgesToSuperview()
            $0.alwaysBounceVertical = true
            $0.backgroundColor = .clear
            $0.scrollIndicatorInsets.top = .messageVideoHeight + 50
            $0.panGestureRecognizer.addTarget(self, action: #selector(userDidPan))
            $0.contentInsetAdjustmentBehavior = .never
        }
        
        UIView().add(toSuperview: scrollView, behind: containerView).customize {
            $0.pinTop(to: scrollView).pinBottom(to: containerView, .top, plus: 50)
            $0.pinLeading(to: scrollView).pinTrailing(to: scrollView).constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
            
            headerTapGesture = $0.addGesture(type: .tap) { [weak self] in self?.headerView.tapped(location: $0.location(in: self?.headerView)) }
            headerDoubleTapGesture = $0.addGesture(type: .doubleTap) { [weak self] _ in self?.headerView.doubleTapped() }
            
            headerTapGesture?.require(toFail: headerDoubleTapGesture!)
        }
        
        containerView.customize {
            $0.pinLeading(to: scrollView).pinTrailing(to: scrollView).pinBottom(to: scrollView)
            $0.pinTop(to: scrollView, plus: .messageVideoHeight).constrainWidth(to: scrollView)
            $0.delegate = self
        }
        
        statusBarCover.add(toSuperview: view).customize {
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.backgroundColor = .black
            
            if content.isTextPost {
                statusBarCover.isHidden = true
            }
        }
        
        statusBarBackground.add(toSuperview: view).customize {
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 50)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.alpha = 0
            
            switch content {
            case .message:  $0.backgroundColor = .lightBackground
            case .textPost: $0.backgroundColor = .darkBlue
            }
        }
        
        closeButton.add(toSuperview: view).customize {
            $0.pinSafely(.top, to: view, atPriority: .required - 2).pinSafely(.trailing, to: view).constrainClose(height: 50)
            $0.pinTop(to: view, relation: .greaterThanOrEqual, plus: 20, atPriority: .required - 1)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.dismiss(animated: true) }
        }
        
        titleLabel.add(toSuperview: statusBarBackground).customize {
            $0.pinBottom(to: statusBarBackground).pinSafely(.top, to: statusBarBackground)
            $0.pinLeading(to: view, plus: .padding).pinTrailing(to: view, plus: -.closeButtonWidth)
            $0.font = .bold(size: 18)
            $0.text = content.title
            $0.textAlignment = .left
            $0.isUserInteractionEnabled = true
            $0.addGesture(type: .tap) { [weak self] _ in self?.scrollView.setContentOffset(x: 0, y: 0) }
            
            switch content {
            case .message:  $0.textColor = .dark
            case .textPost: $0.textColor = .lightBackground
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch content {
        case .message:  return showStatusBarBackground ? .default : .lightContent
        case .textPost: return .lightContent
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIViewController.current == self {
            return .allButUpsideDown
        }
        else {
            return .portrait
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard UIViewController.current == self else { return }
        
        isLandscape = (size.width > size.height)
        scrollView.isScrollEnabled = !isLandscape
        
        if isLandscape {
            scrollView.setContentOffset(x: 0, y: 0)
        }
        
        containerView.isHidden       = isLandscape
        closeButton.isHidden         = isLandscape
        statusBarBackground.isHidden = isLandscape
        statusBarCover.isHidden      = isLandscape
        
        videoConstraint.isActive = isLandscape
        headerView.update(isLandscape: isLandscape)
        
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return isLandscape
    }
    
    deinit {
        print("Video deinit")
        headerView.pause()
    }
    
}

extension ContentViewController: ContentHeaderViewDelegate {
    
    func didUpdate(progress: CGFloat, in view: ContentHeaderView) {
        containerView.progress = progress
        containerView.update(currentTime: Double(progress) * headerView.duration, duration: headerView.duration)
    }
    
    func didUpdate(buffer: CGFloat, in view: ContentHeaderView) {
        containerView.bufferProgress = buffer
    }
    
    func didShowOverlay(in view: ContentHeaderView) {
        containerView.update(isProgressButtonVisible: true)
    }
    
    func didHideOverlay(in view: ContentHeaderView) {
        containerView.update(isProgressButtonVisible: false)
    }
    
    func didPlay(in view: ContentHeaderView) {
        containerView.update(isPlaying: true)
        
        if case .textPost(let post) = content {
            statusBarCover.isHidden = (post.mediaURL == nil)
        }
    }
    
    func didPause(in view: ContentHeaderView) {
        containerView.update(isPlaying: false)
    }
    
}

extension ContentViewController: ContentContainerViewDelegate {
    
    func didSeek(toProgress progress: CGFloat, in view: ContentContainerView) {
        headerView.seek(toProgress: progress)
    }
    
    func didCommit(toProgress progress: CGFloat, in view: ContentContainerView) {
        headerView.commit(toProgress: progress)
    }
    
    func didTapPlayPauseButton(in view: ContentContainerView) {
        headerView.togglePlayback()
    }
    
}

extension ContentViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        check(containerView: containerView, in: self)
        
        scrollAlpha = 1 - scrollView.adjustedOffset.y.map(from: (view.height * 0.25)...(view.height * 0.4), to: 0...1).limited(0, 1)
        
        headerView.update(alpha: scrollAlpha)
    }
    
}
