//
//  ContentHeaderView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit
import Alexandria
import AVFoundation
import MediaPlayer

protocol ContentHeaderViewDelegate: AnyObject {
    func didUpdate(progress: CGFloat, in view: ContentHeaderView)
    func didUpdate(buffer: CGFloat, in view: ContentHeaderView)
    func didShowOverlay(in view: ContentHeaderView)
    func didHideOverlay(in view: ContentHeaderView)
    func didPlay(in view: ContentHeaderView)
    func didPause(in view: ContentHeaderView)
    func didFailToLoadMedia(in view: ContentHeaderView)
    func didReset(in view: ContentHeaderView)
}

final class ContentHeaderView: View {
    
    enum AspectMode {
        case fit
        case fill
    }
    
    private(set) var mediaType: MediaType = .video
    private var aspectMode: AspectMode = .fill
    
    @objc dynamic private(set) var isShowingControls = true
    
    private var content: ContentViewController.Content?
    private var message: Watermark.Message?
    
    private var isDragging = false
    
    private let audioPlayer      = AudioPlayer()
    private let videoView        = VideoView()
    private let dimmerView       = UIView()
    private let loadingIndicator = LoadingView()
    private let titleLabel       = UILabel()
    
    private let imageView = LoadingImageView()
    
    private var isLandscape = false
    private var scrollAlpha: CGFloat = 1
    
    private var overlayTimer: Timer?
    
    private var isLoading = false {
        didSet {
            if isLoading {
                titleLabel.isHidden = true
                loadingIndicator.startAnimating()
            }
            else {
                titleLabel.isHidden = false
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    private var videoFillConstraints: [NSLayoutConstraint] = []
    private var videoFitConstraints: [NSLayoutConstraint] = []
    
    private var leadingVideoConstraint: NSLayoutConstraint?
    private var trailingVideoConstraint: NSLayoutConstraint?
    
    weak var delegate: ContentHeaderViewDelegate?
    
    var duration: TimeInterval {
        switch mediaType {
        case .audio: return audioPlayer.duration.limited(0, .greatestFiniteMagnitude)
        case .video: return videoView.duration.limited(0, .greatestFiniteMagnitude)
        }
    }
    
    var currentTime: TimeInterval {
        switch mediaType {
        case .audio: return audioPlayer.currentTime.limited(0, .greatestFiniteMagnitude)
        case .video: return videoView.currentTime.limited(0, .greatestFiniteMagnitude)
        }
    }
    
    deinit {
        audioPlayer.stop()
        videoView.stop()
        AVAudioSession.configureBackgroundAudio(isEnabled: false)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
    }
    
    func togglePlayback() {
        switch mediaType {
        case .audio:
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            }
            else {
                AVAudioSession.configureBackgroundAudio(isEnabled: true)
                audioPlayer.playFromCurrentTime()
                updateNowPlayingInfo()
            }
        case .video:
            if videoView.isPlaying {
                videoView.pause()
            }
            else {
                AVAudioSession.configureBackgroundAudio(isEnabled: true)
                imageView.isHidden = true
                videoView.playFromCurrentTime()
                hideControls()
                updateNowPlayingInfo()
            }
        }
    }
    
    func addVideoView() {
        videoView.removeFromSuperview()
        videoView.add(toSuperview: self, at: 0).customize {
            videoFillConstraints = [
                $0.constrainSafely(.top, to: self, .top, atPriority: .required - 1),
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
        
        imageView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        audioPlayer.customize {
            $0.delegate = self
            $0.playbackDelegate = self
        }
        
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
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinCenterY(to: self).constrainSize(toFit: .vertical)
            $0.font = .title
            $0.textColor = .lightBackground
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        loadingIndicator.add(toSuperview: self).customize {
            $0.pinCenterX(to: self).pinCenterY(to: self)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
        }
        
        setupRemoteCommands()
    }
    
}

extension ContentHeaderView {
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        let skipBackCommand = commandCenter.skipBackwardCommand
        skipBackCommand.isEnabled = true
        skipBackCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            switch self.mediaType {
            case .audio: return self.audioPlayer.handleSkipBack(event: event) { [weak self] in self?.updateNowPlayingInfo() }
            case .video: return self.videoView.handleSkipBack(event: event) { [weak self] in self?.updateNowPlayingInfo() }
            }
        }
        skipBackCommand.preferredIntervals = [15]
        
        let skipForwardCommand = commandCenter.skipForwardCommand
        skipForwardCommand.isEnabled = true
        skipForwardCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            switch self.mediaType {
            case .audio: return self.audioPlayer.handleSkipForward(event: event) { [weak self] in self?.updateNowPlayingInfo() }
            case .video: return self.videoView.handleSkipForward(event: event) { [weak self] in self?.updateNowPlayingInfo() }
            }
        }
        skipForwardCommand.preferredIntervals = [15]
        
        let playCommand = commandCenter.playCommand
        playCommand.isEnabled = true
        playCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            
            switch self.mediaType {
            case .audio: self.audioPlayer.playFromCurrentTime()
            case .video: self.videoView.playFromCurrentTime()
            }
            
            return .success
        }
        
        let pauseCommand = commandCenter.pauseCommand
        pauseCommand.isEnabled = true
        pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            
            switch self.mediaType {
            case .audio: self.audioPlayer.pause()
            case .video: self.videoView.pause()
            }
            
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let content = content else { return }
        
        switch content {
        case .message(let message):
            MPNowPlayingInfoCenter.update(
                message: message,
                image: imageView.image,
                currentTime: currentTime,
                duration: duration
            )
        case .textPost(let post):
            if let message = message {
                MPNowPlayingInfoCenter.update(
                    message: message,
                    image: imageView.image,
                    currentTime: currentTime,
                    duration: duration
                )
            }
            else {
                MPNowPlayingInfoCenter.update(
                    textPost: post,
                    image: imageView.image,
                    currentTime: currentTime,
                    duration: duration
                )
            }
        }
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
    
    func reset() {
        switch mediaType {
        case .audio: audioPlayer.reset()
        case .video: videoView.reset()
        }
        
        imageView.isHidden = false
        showControls()
        
        delegate?.didReset(in: self)
    }
    
    func showControls() {
        guard !isShowingControls else {
            overlayTimer?.invalidate()
            overlayTimer = nil
            return
        }
        toggleControls()
    }
    
    func toggleControls() {
        
        overlayTimer?.invalidate()
        overlayTimer = nil
        
        if isShowingControls {
            delegate?.didHideOverlay(in: self)
            
            UIView.animate(withDuration: 0.25) {
                self.dimmerView.alpha = 0
                self.titleLabel.alpha = 0
            }
        }
        else {
            delegate?.didShowOverlay(in: self)
            
            UIView.animate(withDuration: 0.25) {
                self.dimmerView.alpha = 1
                self.titleLabel.alpha = 1
            }
        }
        
        isShowingControls.toggle()
    }
    
    func pause() {
        overlayTimer?.invalidate()
        overlayTimer = nil
        
        switch mediaType {
        case .audio: audioPlayer.pause()
        case .video: videoView.pause()
        }
    }
    
    func hideControls() {
        overlayTimer?.invalidate()
        overlayTimer = Timer.once(after: 2) { [weak self] in
            guard let self = self, self.isShowingControls else { return }
            self.toggleControls()
        }
    }
    
    func configure(content: ContentViewController.Content) {
        switch content {
        case .message(let message): configure(message: message)
        case .textPost(let post):   configure(textPost: post)
        }
    }
    
    func configure(message: Watermark.Message) {
        self.content = .message(message)
        
        AVAudioSession.configureBackgroundAudio(isEnabled: true)
        
        imageView.load(url: message.image?.url)
        
        isLoading = true
        
        switch message.mediaAsset {
        case .audio(let asset):
            mediaType = .audio
            audioPlayer.autoPlay = true
            audioPlayer.setup(url: asset.url)
            imageView.isHidden = false
        case .video(let asset):
            mediaType = .video
            videoView.autoPlay = true
            videoView.setup(url: asset.url)
            imageView.isHidden = true
        }
    }
    
    func update(message: Watermark.Message, startTime: TimeInterval? = nil) {
        self.content = .message(message)
        commit(toTime: startTime ?? 0)
    }
    
    func configure(textPost: Contentful.TextPost) {
        self.content = .textPost(textPost)
        
        AVAudioSession.configureBackgroundAudio(isEnabled: true, category: .ambient)
        
        if let image = textPost.image?.url {
            imageView.load(url: image)
            dimmerView.isHidden = false
        }
        else {
            imageView.image = textPost.type.image
            dimmerView.isHidden = true
        }
        
        titleLabel.text = textPost.title
        
        if let media = textPost.media {
            media.fetch { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .value(let data):
                    self.isLoading = true
                    
                    self.message = data.message
                    
                    switch data.mediaType {
                    case .audio:
                        self.mediaType = .audio
                        self.audioPlayer.autoPlay = false
                        self.audioPlayer.setup(url: data.url)
                    case .video:
                        self.mediaType = .video
                        self.videoView.autoPlay = false
                        self.videoView.setup(url: data.url)
                    }
                case .error:
                    self.imageView.isHidden = false
                    self.videoView.isHidden = true
                    self.delegate?.didFailToLoadMedia(in: self)
                    self.showControls()
                }
            }
        }
        else {
            imageView.isHidden = false
            videoView.isHidden = true
            delegate?.didFailToLoadMedia(in: self)
            showControls()
        }
    }
    
    func seek(toProgress progress: CGFloat) {
        guard duration > 0 else { return }
        
        isDragging = true
        
        switch mediaType {
        case .audio: audioPlayer.pause()
        case .video: videoView.pause()
        }
        
        overlayTimer?.invalidate()
        overlayTimer = nil
    }
    
    func commit(toTime time: TimeInterval) {
        guard duration > 0 else { return }
        
        isLoading = true
        
        switch mediaType {
        case .audio:
            audioPlayer.pause()
            audioPlayer.seek(to: time) { [weak self] _ in self?.togglePlayback() }
        case .video:
            videoView.pause()
            videoView.seek(to: time) { [weak self] _ in self?.togglePlayback() }
        }
        
        isDragging = false
    }
    
    func commit(toProgress progress: CGFloat) {
        guard duration > 0 else { return }
        let seekTime = TimeInterval(progress) * duration
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

// MARK: - VideoDelegate

extension ContentHeaderView: VideoDelegate {
    
    func videoReady(_ player: VideoView) {
        guard window != nil, player.playbackState != .paused, player.autoPlay else { return }
        player.playFromCurrentTime()
    }
    
    func videoPlaybackStateDidChange(_ player: VideoView) {
        switch player.playbackState {
        case .playing:
            isLoading = false
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
        
        guard player.playbackState != .paused, player.autoPlay else { return }
        
        hideControls()
        
        guard window != nil else { return }
        
        updateNowPlayingInfo()
    }
    
}

// MARK: - VideoPlaybackDelegate

extension ContentHeaderView: VideoPlaybackDelegate {
    
    func videoCurrentTimeDidChange(_ player: VideoView) {
        guard player.duration > 0 else { return }
        
        let progress = CGFloat(player.currentTime/videoView.duration)
        
        delegate?.didUpdate(progress: progress, in: self)
        
        if progress >= 1 {
            reset()
        }
    }
    
    func videoPlaybackWillStartFromBeginning(_ player: VideoView) {
        
    }
    
    func videoPlaybackDidEnd(_ player: VideoView) {
        
    }
    
    func videoPlaybackWillLoop(_ player: VideoView) {
        
    }
    
}

// MARK: - AudioPlayerDelegate

extension ContentHeaderView: AudioPlayerDelegate {
    
    func playerReady(_ player: AudioPlayer) {
        guard window != nil, player.playbackState != .paused, player.autoPlay else { return }
        player.playFromCurrentTime()
    }
    
    func playerPlaybackStateDidChange(_ player: AudioPlayer) {
        switch player.playbackState {
        case .playing:
            isLoading = false
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
    
    func playerBufferingStateDidChange(_ player: AudioPlayer) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        guard audioPlayer.duration > 0 else { return }
        delegate?.didUpdate(buffer: CGFloat(bufferTime/audioPlayer.duration), in: self)
    }
    
    func playerDidBecomeReadyToPlay(_ player: AudioPlayer) {
        isLoading = false
        
        guard
            player.playbackState != .paused,
            player.autoPlay,
            window != nil
        else { return }
        
        updateNowPlayingInfo()
    }
    
}

// MARK: - AudioPlayerPlaybackDelegate

extension ContentHeaderView: AudioPlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: AudioPlayer) {
        guard player.duration > 0 else { return }
        
        let progress = CGFloat(player.currentTime/player.duration)
        
        delegate?.didUpdate(progress: progress, in: self)
        
        if progress >= 1 {
            reset()
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: AudioPlayer) {
        
    }
    
    func playerPlaybackDidEnd(_ player: AudioPlayer) {
        
    }
    
    func playerPlaybackWillLoop(_ player: AudioPlayer) {
        
    }
    
}
