//
//  MessageViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Alexandria

final class MessageViewController: ViewController, StatusBarViewController {
    
    let message: Watermark.Message
    
    var showStatusBarBackground = false {
        didSet {
            updateStatusBarBackground()
            
            if showStatusBarBackground {
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
    
    private let containerView: MessageContainerView
    
    private let statusBarCover = UIView()
    private let headerView     = MessageHeaderView()
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
    
    required init(message: Watermark.Message) {
        self.message = message
        self.containerView = MessageContainerView(message: message)
        
        super.init(nibName: nil, bundle: nil)
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
        
        headerView.add(toSuperview: view)
        scrollView.add(toSuperview: view)
        containerView.add(toSuperview: scrollView)
        
        headerView.customize {
            $0.pinSafely(.top, to: view).pinBottom(to: containerView, .top, plus: 50, atPriority: .required - 2)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.configure(message: message)
            $0.delegate = self
            
            videoConstraint = $0.constrain(.bottom, to: view, .bottom, atPriority: .required - 1)
            videoConstraint.isActive = false
        }
        
        controlsObserver = headerView.observe(\.isShowingControls, options: .new) { [weak self] headerView, change in
            guard let `self` = self else { return }
            
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
        }
        
        statusBarBackground.add(toSuperview: view).customize {
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 50)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.backgroundColor = .lightBackground
            $0.alpha = 0
        }
        
        closeButton.add(toSuperview: view).customize {
            $0.pinSafely(.top, to: view, atPriority: .required - 2).pinSafely(.trailing, to: view).constrainClose(height: 50)
            $0.pinTop(to: view, relation: .greaterThanOrEqual, plus: 20, atPriority: .required - 1)
            $0.addTarget(for: .touchUpInside) { [weak self] in self?.dismiss(animated: true) }
        }
        
        titleLabel.add(toSuperview: statusBarBackground).customize {
            $0.pinBottom(to: statusBarBackground).pinSafely(.top, to: statusBarBackground)
            $0.pinLeading(to: view, plus: .padding).pinTrailing(to: view, plus: -.closeButtonWidth)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.text = message.title
            $0.isUserInteractionEnabled = true
            $0.addGesture(type: .tap) { [weak self] _ in self?.scrollView.setContentOffset(x: 0, y: 0) }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return showStatusBarBackground ? .default : .lightContent
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

extension MessageViewController: MessageHeaderViewDelegate {
    
    func didUpdate(progress: CGFloat, in view: MessageHeaderView) {
        containerView.progress = progress
        containerView.update(currentTime: Double(progress) * headerView.duration, duration: headerView.duration)
    }
    
    func didUpdate(buffer: CGFloat, in view: MessageHeaderView) {
        containerView.bufferProgress = buffer
    }
    
    func didShowOverlay(in view: MessageHeaderView) {
        containerView.update(isProgressButtonVisible: true)
    }
    
    func didHideOverlay(in view: MessageHeaderView) {
        containerView.update(isProgressButtonVisible: false)
    }
    
    func didPlay(in view: MessageHeaderView) {
        containerView.update(isPlaying: true)
    }
    
    func didPause(in view: MessageHeaderView) {
        containerView.update(isPlaying: false)
    }
    
}

extension MessageViewController: MessageContainerViewDelegate {
    
    func didSeek(toProgress progress: CGFloat, in view: MessageContainerView) {
        headerView.seek(toProgress: progress)
    }
    
    func didCommit(toProgress progress: CGFloat, in view: MessageContainerView) {
        headerView.commit(toProgress: progress)
    }
    
    func didTapPlayPauseButton(in view: MessageContainerView) {
        headerView.togglePlayback()
    }
    
}

extension MessageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        check(containerView: containerView, in: self)
        
        scrollAlpha = 1 - scrollView.adjustedOffset.y.map(from: (view.height * 0.25)...(view.height * 0.4), to: 0...1).limited(0, 1)
        
        headerView.update(alpha: scrollAlpha)
    }
    
}
