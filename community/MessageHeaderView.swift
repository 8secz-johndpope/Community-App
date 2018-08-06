//
//  MessageHeaderView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit
import Alexandria
import AVFoundation
import MediaPlayer

protocol MessageHeaderViewDelegate: AnyObject {
    func didUpdate(progress: CGFloat, in view: MessageHeaderView)
    func didUpdate(buffer: CGFloat, in view: MessageHeaderView)
    func didShowOverlay(in view: MessageHeaderView)
    func didHideOverlay(in view: MessageHeaderView)
    func didPlay(in view: MessageHeaderView)
    func didPause(in view: MessageHeaderView)
}

final class MessageHeaderView: View {
    
    enum AspectMode {
        case fit
        case fill
    }
    
    private var aspectMode: AspectMode = .fill
    
    @objc dynamic private(set) var isShowingControls = true
    
    private var message: Watermark.Message?
    private var isDragging = false
    
    private let videoView        = VideoView()
    private let dimmerView       = UIView()
    private let loadingIndicator = LoadingView()
    
    private let imageView = LoadingImageView()
    
    private var isLandscape = false
    private var scrollAlpha: CGFloat = 1
    
    private var overlayTimer: Timer?
    
    private var isLoading = false {
        didSet {
            if isLoading {
                loadingIndicator.startAnimating()
            }
            else {
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    private var videoFillConstraints: [NSLayoutConstraint] = []
    private var videoFitConstraints: [NSLayoutConstraint] = []
    
    private var leadingVideoConstraint: NSLayoutConstraint?
    private var trailingVideoConstraint: NSLayoutConstraint?
    
    weak var delegate: MessageHeaderViewDelegate?
    
    var duration: TimeInterval {
        return videoView.duration.limited(0, .greatestFiniteMagnitude)
    }
    
    deinit {
        videoView.stop()
        configureBackgroundAudio(isEnabled: false)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
    }
    
    func togglePlayback() {
        if videoView.isPlaying {
            videoView.pause()
        }
        else {
            videoView.playFromCurrentTime()
            hideControls()
        }
    }
    
    func addVideoView() {
        videoView.removeFromSuperview()
        videoView.add(toSuperview: self, at: 0).customize {
            videoFillConstraints = [
                $0.constrain(.top, to: self, .top, atPriority: .required - 1),
                $0.constrain(.bottom, to: self, .bottom, atPriority: .required - 1),
                $0.constrain(.centerX, to: self, .centerX, atPriority: .required - 1)
            ]
            
            videoFitConstraints = [
                $0.constrain(.leading, to: self, .leading, atPriority: .required - 1),
                $0.constrain(.trailing, to: self, .trailing, atPriority: .required - 1),
                $0.constrain(.centerY, to: self, .centerY, atPriority: .required - 1)
            ]
            NSLayoutConstraint.deactivate(videoFitConstraints)
            
            leadingVideoConstraint = $0.constrain(.leading, .lessThanOrEqual, to: self, .leading)
            trailingVideoConstraint = $0.constrain(.trailing, .greaterThanOrEqual, to: self, .trailing)
            
            $0.autoDimension = .width
        }
    }
    
    override func setup() {
        
        backgroundColor = .clear
        constrainWidth(to: 100, .greaterThanOrEqual)
        
        videoView.customize {
            addVideoView()
            
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .black
            $0.videoGravity = .resizeAspectFill
            $0.delegate = self
            $0.playbackDelegate = self
        }
        
        dimmerView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .dimmer
            $0.isUserInteractionEnabled = false
        }
        
        loadingIndicator.add(toSuperview: self).customize {
            $0.pinCenterX(to: self).pinCenterY(to: self)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
        }
        
        setupRemoteCommands()
    }
    
}

extension MessageHeaderView {
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        let skipBackCommand = commandCenter.skipBackwardCommand
        skipBackCommand.isEnabled = true
        skipBackCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            if let currentTime = self?.videoView.currentTime, let duration = self?.videoView.duration, currentTime >= 0, duration > 0 {
                let newTime = (currentTime - 15).limited(0, duration)
                self?.videoView.seek(to: newTime)
                return .success
            }
            else {
                return .commandFailed
            }
        }
        skipBackCommand.preferredIntervals = [15]
        
        let skipForwardCommand = commandCenter.skipForwardCommand
        skipForwardCommand.isEnabled = true
        skipForwardCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            if let currentTime = self?.videoView.currentTime, let duration = self?.videoView.duration, currentTime >= 0, duration > 0 {
                let newTime = (currentTime + 15).limited(0, duration)
                self?.videoView.seek(to: newTime)
                return .success
            }
            else {
                return .commandFailed
            }
        }
        skipForwardCommand.preferredIntervals = [15]
        
        let playCommand = commandCenter.playCommand
        playCommand.isEnabled = true
        playCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.videoView.playFromCurrentTime()
            return .success
        }
        
        let pauseCommand = commandCenter.pauseCommand
        pauseCommand.isEnabled = true
        pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.videoView.pause()
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard
            let title = message?.title,
            let organization = message?.series.title,
            let authors = message?.speakers.map({ $0.name }).joined(separator: ", "),
            let url = message?.videoAsset?.url,
            //            let image = authorView.image,
            videoView.duration > 0
        else { return }
        
        var info: [String : Any] = [
            MPMediaItemPropertyTitle : title,
            MPMediaItemPropertyAlbumTitle : organization,
            MPMediaItemPropertyArtist : authors,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: videoView.currentTime),
            MPMediaItemPropertyPlaybackDuration : NSNumber(value: videoView.duration),
            MPMediaItemPropertyAssetURL : url
        ]
        
        if let image = imageView.image {
            print("Image: \(image)")
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
        }
        else {
            print("No image")
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    func update(alpha: CGFloat) {
        scrollAlpha = alpha
    }
    
    func tapped(location: CGPoint) {
        toggleControls()
    }
    
    func doubleTapped() {
        adjust(
            aspectMode: (self.aspectMode == .fill) ? .fit : .fill,
            animated: true
        )
    }
    
    func adjust(aspectMode: AspectMode, animated: Bool) {
        guard aspectMode != self.aspectMode else { return }
        
        switch self.aspectMode {
        case .fill:
            NSLayoutConstraint.deactivate(videoFillConstraints)
            NSLayoutConstraint.activate(videoFitConstraints)
            
            videoView.autoDimension = .height
            
            self.aspectMode = .fit
        case .fit:
            NSLayoutConstraint.activate(videoFillConstraints)
            NSLayoutConstraint.deactivate(videoFitConstraints)
            
            videoView.autoDimension = .width
            
            self.aspectMode = .fill
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func toggleControls() {
        
        overlayTimer?.invalidate()
        overlayTimer = nil
        
        if isShowingControls {
            delegate?.didHideOverlay(in: self)
            
            UIView.animate(withDuration: 0.25) {
                self.dimmerView.alpha = 0
            }
        }
        else {
            delegate?.didShowOverlay(in: self)
            
            UIView.animate(withDuration: 0.25) {
                self.dimmerView.alpha = 1
            }
        }
        
        isShowingControls = !isShowingControls
    }
    
    func pause() {
        overlayTimer?.invalidate()
        overlayTimer = nil
        
        videoView.pause()
    }
    
    func hideControls() {
        overlayTimer?.invalidate()
        overlayTimer = Timer.once(after: 2) { [weak self] in
            guard let `self` = self, self.isShowingControls else { return }
            self.toggleControls()
        }
    }
    
    func configureBackgroundAudio(isEnabled: Bool) {
        if isEnabled {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            catch {
                print("""
                    ===========================================================================
                    
                    Error starting audio session: \(error.localizedDescription)
                    
                    ===========================================================================
                    """)
            }
        }
        else {
            do {
                UIApplication.shared.endReceivingRemoteControlEvents()
                try AVAudioSession.sharedInstance().setActive(false)
            }
            catch {
                print("""
                    ===========================================================================
                    
                    Error deactivating audio session: \(error.localizedDescription)
                    
                    ===========================================================================
                    """)
            }
        }
    }
    
    func configure(message: Watermark.Message) {
        self.message = message
        
        configureBackgroundAudio(isEnabled: true)
        
        imageView.load(url: message.wideImage?.url)
        
        isLoading = true
        
//        videoView.setup(url: "https://aaiaxqp-lh.akamaihd.net/i/porch_live_1@52223/master.m3u8")
        videoView.setup(url: message.videoAsset?.url)
    }
    
    func update(message: Watermark.Message, startTime: TimeInterval? = nil) {
        self.message = message
        commit(toTime: startTime ?? 0)
    }
    
    func seek(toProgress progress: CGFloat) {
        guard videoView.duration > 0 else { return }
        
        isDragging = true
        
        videoView.pause()
        
        overlayTimer?.invalidate()
        overlayTimer = nil
    }
    
    func commit(toTime time: TimeInterval) {
        guard videoView.duration > 0 else { return }
        
        isLoading = true
        
        videoView.pause()
        videoView.seek(to: time) { [weak self] _ in
            self?.videoView.playFromCurrentTime()
            self?.hideControls()
        }
        
        isDragging = false
    }
    
    func commit(toProgress progress: CGFloat) {
        guard videoView.duration > 0 else { return }
        let seekTime = TimeInterval(progress) * videoView.duration
        commit(toTime: seekTime)
    }
    
    func update(isLandscape: Bool) {
        self.isLandscape = isLandscape
        
        if isLandscape {
            leadingVideoConstraint?.isActive = false
            trailingVideoConstraint?.isActive = false
            
            videoView.videoGravity = .resizeAspect
        }
        else {
            leadingVideoConstraint?.isActive = true
            trailingVideoConstraint?.isActive = true
            
            videoView.videoGravity = .resizeAspectFill
        }
    }
    
}

//extension MessageHeaderView {
//
//    func prepareForTransition() {
//        videoView.alpha = 0
//        dimmerView.alpha = 0
//        loadingIndicator.alpha = 0
//    }
//
//    func transition(duration: TimeInterval, delay: TimeInterval) {
//        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
//            self.loadingIndicator.alpha = 1
//        }, completion: nil)
//    }
//
//    func finishTransition() {
//        backgroundColor = .black
//        videoView.alpha = 1
//        dimmerView.alpha = 1
//    }
//
//}

extension MessageHeaderView: VideoDelegate {
    
    func videoReady(_ player: VideoView) {
        guard window != nil, player.playbackState != .paused else { return }
        player.playFromCurrentTime()
    }
    
    func videoPlaybackStateDidChange(_ player: VideoView) {
        switch player.playbackState {
        case .playing:
            delegate?.didPlay(in: self)
        case .paused:
            if !isShowingControls {
                toggleControls()
            }
            delegate?.didPause(in: self)
        case .stopped:
            delegate?.didPause(in: self)
        case .failed(let error):
            delegate?.didPause(in: self)
            UIAlertController.alert(title: "Error", message: error.localizedDescription).addAction(title: "OK").present()
        }
    }
    
    func videoBufferingStateDidChange(_ player: VideoView) {
        
    }
    
    func videoBufferTimeDidChange(_ bufferTime: Double) {
        guard videoView.duration > 0 else { return }
        delegate?.didUpdate(buffer: CGFloat(bufferTime/videoView.duration), in: self)
    }
    
    func videoDidBecomeReadyToPlay(_ player: VideoView) {
        
        isLoading = false
        
        guard player.playbackState != .paused else { return }
        
        hideControls()
        
        guard window != nil else { return }
        
        updateNowPlayingInfo()
    }
    
}

extension MessageHeaderView: VideoPlaybackDelegate {
    
    func videoCurrentTimeDidChange(_ player: VideoView) {
        guard player.duration > 0 else { return }
        
        let progress = CGFloat(player.currentTime/videoView.duration)
        
        delegate?.didUpdate(progress: progress, in: self)
        
        if progress >= 1 {
            videoView.stop()
        }
    }
    
    func videoPlaybackWillStartFromBeginning(_ player: VideoView) {
        
    }
    
    func videoPlaybackDidEnd(_ player: VideoView) {
        
    }
    
    func videoPlaybackWillLoop(_ player: VideoView) {
        
    }
    
}
