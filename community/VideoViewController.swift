//
//  VideoViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import UIKit
import AVFoundation

final class TriangleView : UIView {
    
    var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX/2, y: rect.maxY))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}

final class VideoViewController: ViewController {
    
    private let blurView           = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let videoContainerView = UIView()
    private let videoView          = VideoView()
    private let loadingIndicator   = LoadingView()
    private let videoButton        = UIButton()
    
    private var startingButtonMinY: CGFloat?
    
    deinit {
        videoView.stop()
        AVAudioSession.configureBackgroundAudio(isEnabled: false)
    }
    
    override func setup() {
        super.setup()
        
        AVAudioSession.configureBackgroundAudio(isEnabled: true)
        
        blurView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.addGesture(type: .tap) { [weak self] _ in self?.hide() }
        }
        
        videoButton.add(toSuperview: view).customize {
            $0.pinTrailing(to: view, plus: -.padding).pinTop(to: view, plus: startingButtonMinY ?? (.safeTop + 44))
            $0.constrainHeight(to: 45).constrainWidth(to: 45)
            $0.setTitle(Icon.video.string, for: .normal)
            $0.setTitleColor(.lightBackground, for: .normal)
            $0.setTitleColor(.light, for: .highlighted)
            $0.contentHorizontalAlignment = .right
            $0.adjustsImageWhenHighlighted = false
            $0.titleLabel?.font = .fontAwesome(.solid, size: 27)
            $0.titleEdgeInsets = UIEdgeInsets(top: 5)
            $0.isUserInteractionEnabled = false
        }
        
        videoContainerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view, plus: .padding).pinTrailing(to: view, plus: -.padding)
            $0.pinTop(to: videoButton, .bottom)
            $0.backgroundColor = .clear
        }
        
        videoView.add(toSuperview: videoContainerView).customize {
            $0.pinLeading(to: videoContainerView).pinTrailing(to: videoContainerView)
            $0.pinTop(to: videoContainerView, plus: 10).pinBottom(to: videoContainerView)
            $0.autoDimension = .width
            $0.backgroundColor = .black
            $0.borderColor = .white
            $0.cornerRadius = 8
            $0.borderWidth = 2
            $0.delegate = self
            $0.playbackDelegate = self
            $0.setup(url: Contentful.LocalStorage.intro?.videoURL)
        }
        
        loadingIndicator.add(toSuperview: videoView).customize {
            $0.pinCenterX(to: videoView).pinCenterY(to: videoView)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.startAnimating()
        }
        
        TriangleView(superview: videoContainerView).customize {
            $0.constrainWidth(to: 20).constrainHeight(to: 10)
            $0.pinTop(to: videoContainerView).pinTrailing(to: videoContainerView, plus: -10)
            $0.backgroundColor = .clear
            $0.color = .white
            $0.transform = .rotate(.pi)
        }
    }
    
    func show(buttonMinY: CGFloat, in viewController: UIViewController? = .current) {
        
        startingButtonMinY = buttonMinY
        blurView.effect = nil
        videoContainerView.alpha = 0
        
        modalPresentationStyle = .overCurrentContext
        viewController?.present(self, animated: false) {
            UIView.animate(withDuration: 0.25) {
                self.blurView.effect = UIBlurEffect(style: .light)
                self.videoContainerView.alpha = 1
            }
        }
    }
    
    func hide() {
        videoView.stop()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.effect = nil
            self.videoContainerView.alpha = 0
        }, completion: { _ in self.dismiss(animated: false) })
    }
    
}

extension VideoViewController: VideoDelegate {
    
    func videoReady(_ player: VideoView) {}
    
    func videoPlaybackStateDidChange(_ player: VideoView) {
        switch player.playbackState {
        case .playing:
            loadingIndicator.stopAnimating()
        case .paused:
            break
        case .stopped:
            break
        case .failed:
            hide()
        }
    }
    
    func videoBufferingStateDidChange(_ player: VideoView) {}
    
    func videoBufferTimeDidChange(_ bufferTime: Double) {}
    
    func videoDidBecomeReadyToPlay(_ player: VideoView) {
        loadingIndicator.stopAnimating()
    }
    
}

extension VideoViewController: VideoPlaybackDelegate {
    
    func videoCurrentTimeDidChange(_ player: VideoView) {
        guard player.duration > 0 else { return }
        
        let progress = CGFloat(player.currentTime/videoView.duration)
        
        if progress >= 1 {
            videoView.stop()
            hide()
        }
    }
    
    func videoPlaybackWillStartFromBeginning(_ player: VideoView) {}
    
    func videoPlaybackDidEnd(_ player: VideoView) {}
    
    func videoPlaybackWillLoop(_ player: VideoView) {}
    
}
