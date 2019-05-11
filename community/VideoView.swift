//
//  VideoView.swift
//  community
//
//  Created by Jonathan Landon on 7/15/18.
//

import Foundation
import Alexandria
import AVFoundation
import UIKit
import AVKit
import MediaPlayer

// MARK: - PlayerDelegate

/// Player delegate protocol
protocol VideoDelegate: AnyObject {
    func videoReady(_ player: VideoView)
    func videoPlaybackStateDidChange(_ player: VideoView)
    func videoBufferingStateDidChange(_ player: VideoView)
    func videoBufferTimeDidChange(_ bufferTime: Double)
    func videoDidBecomeReadyToPlay(_ player: VideoView)
}


/// Player playback protocol
protocol VideoPlaybackDelegate: AnyObject {
    func videoCurrentTimeDidChange(_ player: VideoView)
    func videoPlaybackWillStartFromBeginning(_ player: VideoView)
    func videoPlaybackDidEnd(_ player: VideoView)
    func videoPlaybackWillLoop(_ player: VideoView)
}

struct BackgroundVideo {
    static var player: AVPlayer?
}

final class VideoView: UIView {
    
    enum AutoDimension {
        case none
        case width
        case height
    }
    
    private let isLoggingEnabled = false
    
    private var playerRateObserver: NSKeyValueObservation?
    private var playerStatusObserver: NSKeyValueObservation?
    
    private var itemStatusObserver: NSKeyValueObservation?
    private var itemEmptyBufferObserver: NSKeyValueObservation?
    private var itemKeepUpObserver: NSKeyValueObservation?
    private var itemLoadedTimeRangesObserver: NSKeyValueObservation?
    
    private var layerReadyForDisplayObserver: NSKeyValueObservation?
    
    private var widthConstraint = NSLayoutConstraint()
    private var heightConstraint = NSLayoutConstraint()
    
    var naturalSize: CGSize? {
        return item?.asset.tracks.first?.naturalSize
    }
    
    private var lastDimensions: CGSize = .zero {
        didSet {
            guard
                lastDimensions.height > 0,
                oldValue.height > 0,
                lastDimensions.width/lastDimensions.height != oldValue.width/oldValue.height
            else { return }
            
            DispatchQueue.main.async {
                self.removeConstraints([self.widthConstraint, self.heightConstraint])
                
                self.widthConstraint = self.constrain(.width, to: self, .height, times: self.lastDimensions.width/self.lastDimensions.height, atPriority: .required - 1)
                self.heightConstraint = self.constrain(.height, to: self, .width, times: self.lastDimensions.height/self.lastDimensions.width, atPriority: .required - 1)
                
                switch self.autoDimension {
                case .none:
                    self.widthConstraint.isActive = false
                    self.heightConstraint.isActive = false
                case .height:
                    self.widthConstraint.isActive = false
                    self.heightConstraint.isActive = true
                case .width:
                    self.widthConstraint.isActive = true
                    self.heightConstraint.isActive = false
                }
            }
        }
    }
    
    private var isBackgrounded = false
    
    var autoDimension: AutoDimension = .none {
        didSet {
            switch autoDimension {
            case .none:
                widthConstraint.isActive = false
                heightConstraint.isActive = false
            case .height:
                widthConstraint.isActive = false
                heightConstraint.isActive = true
            case .width:
                widthConstraint.isActive = true
                heightConstraint.isActive = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        player = AVPlayer()
        player?.actionAtItemEnd = .pause
        timeObserver = nil
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspect
        
        if #available(iOS 11.0, *) {
            accessibilityIgnoresInvertColors = true
        }
        
        self.widthConstraint = self.constrain(.width, to: self, .height, times: 16/9, atPriority: .required - 1)
        self.widthConstraint.isActive = false
        
        self.heightConstraint = self.constrain(.height, to: self, .width, times: 9/16, atPriority: .required - 1)
        self.heightConstraint.isActive = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        player = AVPlayer()
        player?.actionAtItemEnd = .pause
        timeObserver = nil
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspect
        
        if #available(iOS 11.0, *) {
            accessibilityIgnoresInvertColors = true
        }
    }
    
    deinit {
        player?.pause()
        
        printAccessLog()
        
        setup(item: nil)
        
        removePlayerObservers()
        
        delegate = nil
        removeApplicationObservers()
        
        playbackDelegate = nil
        removePlayerLayerObservers()
        
        player = nil
        
        BackgroundVideo.player = nil
    }
    
    func handleSkipBack(event: MPRemoteCommandEvent, completion: @escaping () -> Void) -> MPRemoteCommandHandlerStatus {
        guard let skipEvent = event as? MPSkipIntervalCommandEvent, let player = player else { return .commandFailed }
        
        let currentTime = player.currentTime()
        let interval = CMTime(seconds: skipEvent.interval, preferredTimescale: 1000)
        let skipTime = CMTimeSubtract(currentTime, interval)
        
        player.seek(to: skipTime) { _ in completion() }
        
        return .success
    }
    
    func handleSkipForward(event: MPRemoteCommandEvent, completion: @escaping () -> Void) -> MPRemoteCommandHandlerStatus {
        guard let skipEvent = event as? MPSkipIntervalCommandEvent, let player = player else { return .commandFailed }
        
        let currentTime = player.currentTime()
        let interval = CMTime(seconds: skipEvent.interval, preferredTimescale: 1000)
        let skipTime = CMTimeAdd(currentTime, interval)
        
        player.seek(to: skipTime) { _ in completion() }
        
        return .success
    }
    
    func printAccessLog() {
        guard isLoggingEnabled else { return }
        
        let log = item?.accessLog()
        
        print("Events: \(log?.events.count ?? -1)")
        
        for event in log?.events ?? [] {
            print("""
                -------------------------------------------------------
                
                Average audio bitrate: \(event.averageAudioBitrate)
                Average video bitrate: \(event.averageVideoBitrate)
                Duration watched: \(event.durationWatched)
                Number of stalls: \(event.numberOfStalls)
                Playback type: \(event.playbackType ?? "null")
                Startup time: \(event.startupTime)
                Download overdue: \(event.downloadOverdue)
                Indicated average bitrate: \(event.indicatedAverageBitrate)
                Indicated bitrate: \(event.indicatedBitrate)
                Observed bitrate: \(event.observedBitrate)
                Number of bytes transferred: \(event.numberOfBytesTransferred)
                Number of dropped video frames: \(event.numberOfDroppedVideoFrames)
                Number of media requests: \(event.numberOfMediaRequests)
                Playback session ID: \(event.playbackSessionID ?? "null")
                Switch bitrate: \(event.switchBitrate)
                
                -------------------------------------------------------
                """)
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: VideoDelegate?
    weak var playbackDelegate: VideoPlaybackDelegate?
    
    override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    var autoPlay = true
    
    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    
    var videoGravity: AVLayerVideoGravity {
        get { return playerLayer.videoGravity }
        set { playerLayer.videoGravity = newValue }
    }
    
    var isPlaying: Bool {
        return playbackState == .playing
    }
    
    private var player: AVPlayer?
    private var asset: AVAsset?
    private var item: AVPlayerItem?
    private var timeObserver: Any?
    private var seekTimeRequested: TimeInterval?
    private let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    ])
    
    /// Mutes audio playback when true.
    var isMuted: Bool {
        get { return player?.isMuted ?? false }
        set { player?.isMuted = newValue }
    }
    
    /// Volume for the player, ranging from 0.0 to 1.0 on a linear scale.
    var volume: Float {
        get { return player?.volume ?? 0 }
        set { player?.volume = newValue }
    }
    
    
    /// Playback automatically loops continuously when true.
    var playbackLoops: Bool {
        get {
            return (player?.actionAtItemEnd == AVPlayer.ActionAtItemEnd.none) as Bool
        }
        set {
            if newValue == true {
                player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
            }
            else {
                player?.actionAtItemEnd = .pause
            }
        }
    }
    
    /// Playback freezes on last frame frame at end when true.
    var playbackFreezesAtEnd: Bool = true
    
    /// Current playback state of the Player.
    var playbackState: PlaybackState = .stopped {
        didSet {
            if playbackState != oldValue {
                DispatchQueue.onMain { self.delegate?.videoPlaybackStateDidChange(self) }
            }
        }
    }
    
    /// Current buffering state of the Player.
    var bufferingState: BufferingState = .unknown {
        didSet {
            if bufferingState != oldValue {
                self.delegate?.videoBufferingStateDidChange(self)
            }
        }
    }
    
    /// Media playback's current time.
    var currentTime: TimeInterval {
        guard let item = item else { return CMTime.indefinite.seconds }
        return item.currentTime().seconds
    }
    
    /// Media plaback's duration.
    var duration: TimeInterval {
        guard let item = item else { return CMTime.indefinite.seconds }
        return item.duration.seconds
    }
    
    var progress: CGFloat {
        guard currentTime >= 0, duration > 0 else { return 0 }
        return CGFloat(currentTime / duration)
    }
    
}

extension VideoView {
    
    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
        case failed(PlaybackError)
        
        static func ==(lhs: PlaybackState, rhs: PlaybackState) -> Bool {
            switch (lhs, rhs) {
            case (.stopped, .stopped): return true
            case (.playing, .playing): return true
            case (.paused, .paused):   return true
            case (.failed, .failed):   return true
            default:                   return false
            }
        }
    }
    
    enum BufferingState {
        case unknown
        case ready
        case delayed
    }
    
    enum PlaybackError: Swift.Error, LocalizedError {
        case ns(NSError?)
        case notPlayable
        case failedToPlayToEndTime
        case avPlayerFailed
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .ns(let error):         return error?.localizedDescription
            case .notPlayable:           return "This video is not playable"
            case .failedToPlayToEndTime: return "We encountered an error playing this video"
            case .avPlayerFailed:        return "We encountered an error playing this video"
            case .unknown:               return "An unexpected error occurred"
            }
        }
    }
    
}

// MARK: - Setup

extension VideoView {
    
    enum Keys: String {
        case tracks
        case playable
        case duration
        
        static var all: [String] {
            let keys: [Keys] = [.tracks, .playable, .duration]
            return keys.map { $0.rawValue }
        }
    }
    
    func setup(url: URL?) {
        
        // ensure everything is reset beforehand
        if isPlaying {
            pause()
        }
        
        setup(item: nil)
        
        removePlayerLayerObservers()
        removePlayerObservers()
        removeApplicationObservers()
        
        if let url = url {
            let asset = AVURLAsset(url: url)
            setup(asset: asset)
        }
        
        addPlayerLayerObservers()
        addPlayerObservers()
        addApplicationObservers()
    }
    
    func setup(asset: AVAsset) {
        if isPlaying {
            pause()
        }
        
        bufferingState = .unknown
        
        self.asset = asset
        
        self.asset?.loadValuesAsynchronously(forKeys: Keys.all) {
            for key in Keys.all {
                var error: NSError? = nil
                let status = self.asset?.statusOfValue(forKey: key, error:&error)
                if status == .failed {
                    self.playbackState = .failed(.ns(error))
                    return
                }
            }
            
            if let asset = self.asset {
                if !asset.isPlayable {
                    self.playbackState = .failed(.notPlayable)
                    return
                }
                
                DispatchQueue.onMain {
                    let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
                    self.setup(item: playerItem)
                }
            }
        }
    }
    
    private func setup(item: AVPlayerItem?) {
        
        removeItemObservers()
        
        item?.remove(videoOutput)
        
        self.item = item
        
        if let seek = seekTimeRequested, self.item != nil {
            seekTimeRequested = nil
            self.seek(to: seek)
        }
        
        addItemObservers()
        
        item?.add(videoOutput)
        
        if autoPlay {
            player?.rate = 1
        }
        
        player?.replaceCurrentItem(with: self.item)
        
        // update new playerItem settings
        if playbackLoops {
            player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        }
        else {
            player?.actionAtItemEnd = .pause
        }
    }
    
}

// MARK: - Playback

extension VideoView {
    
    /// Stops media and seeks to the beginning.
    func reset() {
        stop()
        player?.seek(to: .zero)
    }
    
    /// Begins playback of the media from the beginning.
    func playFromBeginning() {
        playbackDelegate?.videoPlaybackWillStartFromBeginning(self)
        player?.seek(to: .zero)
        playFromCurrentTime()
    }
    
    /// Begins playback of the media from the current time.
    public func playFromCurrentTime() {
        playbackState = .playing
        player?.play()
    }
    
    /// Pauses playback of the media.
    public func pause() {
        if playbackState != .playing {
            return
        }
        
        player?.pause()
        playbackState = .paused
    }
    
    /// Stops playback of the media.
    public func stop() {
        if playbackState == .stopped {
            return
        }
        
        player?.pause()
        playbackState = .stopped
        playbackDelegate?.videoPlaybackDidEnd(self)
    }
    
    /// Updates playback to the specified time.
    ///
    /// - Parameter time: The time to switch to move the playback.
    func seek(to time: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        if let playerItem = item {
            let timescale = playerItem.asset.duration.timescale
            let time = CMTime(seconds: time, preferredTimescale: timescale)
            guard ![.invalid, .indefinite, .positiveInfinity, .negativeInfinity].contains(time) else { return }
            playerItem.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completion)
        }
        else {
            seekTimeRequested = time
        }
    }
    
}

// MARK: NSNotifications

extension VideoView {
    
    // MARK: AVPlayerItem
    
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        if playbackLoops {
            playbackDelegate?.videoPlaybackWillLoop(self)
            player?.seek(to: .zero)
        }
        else {
            if playbackFreezesAtEnd == true {
                stop()
            }
            else {
                player?.seek(to: .zero) { [weak self] _ in self?.stop() }
            }
        }
    }
    
    @objc private func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        playbackState = .failed(.failedToPlayToEndTime)
    }
    
    @objc private func playerItemTimeJumped(_ notification: Notification) {
        
    }
    
    @objc private func playerItemPlaybackStalled(_ notification: Notification) {
        
    }
    
    @objc private func playerItemNewErrorLogEntry(_ notification: Notification) {
        
    }
    
    @objc private func playerItemNewAccessLogEntry(_ notification: Notification) {
        
    }
    
}

// MARK: UIApplication

extension VideoView {
    
    private func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    private func removeApplicationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Handlers
    
    @objc private func handleApplicationWillResignActive(_ notification: Notification) {
        isBackgrounded = true
    }
    
    @objc private func handleApplicationWillEnterForeground(_ notification: Notification) {
        isBackgrounded = false
        guard window != nil else { return }
        
        playerLayer.player = player
        playerLayer.isHidden = false
    }
    
    @objc private func handleApplicationDidEnterBackground(_ notification: Notification) {
        isBackgrounded = true
        guard window != nil else { return }
        playerLayer.player = nil
    }
    
    @objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
        isBackgrounded = false
        guard window != nil else { return }
        
        playerLayer.player = player
        playerLayer.isHidden = false
    }
    
}

// MARK: - Observer setup

extension VideoView {
    
    // MARK: AVPlayerLayerObservers
    
    private func addPlayerLayerObservers() {
        layerReadyForDisplayObserver = playerLayer.observe(\.isReadyForDisplay) { [weak self] _, change in self?.layerIsReadyForDisplay(change: change) }
    }
    
    private func removePlayerLayerObservers() {
        layerReadyForDisplayObserver = nil
    }
    
    // MARK: AVPlayerObservers
    
    private func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: .main) { [weak self] timeInterval in
            guard let self = self else { return }
            self.playbackDelegate?.videoCurrentTimeDidChange(self)
        }
        
        playerRateObserver = player?.observe(\.rate) { [weak self] _, change in self?.playerRate(change: change) }
        playerStatusObserver = player?.observe(\.status) { [weak self] _, change in self?.playerStatus(change: change) }
    }
    
    private func removePlayerObservers() {
        if let observer = self.timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        playerRateObserver = nil
        playerStatusObserver = nil
    }
    
    // MARK: AVPlayerItemObservers
    
    private func addItemObservers() {
        itemEmptyBufferObserver = item?.observe(\.isPlaybackBufferEmpty) { [weak self] _, change in self?.itemPlaybackBufferEmpty(change: change) }
        itemKeepUpObserver = item?.observe(\.isPlaybackLikelyToKeepUp) { [weak self] _, change in self?.itemKeepUp(change: change) }
        itemStatusObserver = item?.observe(\.status) { [weak self] _, change in self?.itemStatus(change: change) }
        itemLoadedTimeRangesObserver = item?.observe(\.loadedTimeRanges) { [weak self] _, change in self?.itemLoadedTimeRanges(change: change) }
        
        if let updatedPlayerItem = item {
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemTimeJumped(_:)), name: .AVPlayerItemTimeJumped, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlaybackStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemNewErrorLogEntry(_:)), name: .AVPlayerItemNewErrorLogEntry, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemNewAccessLogEntry(_:)), name: .AVPlayerItemNewAccessLogEntry, object: updatedPlayerItem)
        }
    }
    
    private func removeItemObservers() {
        itemEmptyBufferObserver = nil
        itemKeepUpObserver = nil
        itemStatusObserver = nil
        itemLoadedTimeRangesObserver = nil
        
        if let currentPlayerItem = self.item {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: currentPlayerItem)
        }
    }
}

// MARK: - Observers

extension VideoView {
    
    // MARK: Layer observation
    
    private func layerIsReadyForDisplay(change: NSKeyValueObservedChange<Bool>) {
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Layer isReadyForDisplay: \(playerLayer.isReadyForDisplay)
                Date: \(Date().second)
            """)
        }
        
        DispatchQueue.onMain { self.delegate?.videoReady(self) }
    }
    
    // MARK: Player observation
    
    private func playerRate(change: NSKeyValueObservedChange<Float>) {
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Player rate: \(player?.rate ?? -1)
                Date: \(Date().second)
            """)
        }
    }
    
    private func playerStatus(change: NSKeyValueObservedChange<AVPlayer.Status>) {
        guard let player = player else { return }
        
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Player status: \(player.status)
                Date: \(Date().second)
            """)
        }
        
        if case .readyToPlay = player.status {
            playerLayer.player = player
            playerLayer.isHidden = false
        }
    }
    
    // MARK: Item observation
    
    private func itemStatus(change: NSKeyValueObservedChange<AVPlayerItem.Status>) {
        guard let item = self.item else { return }
        
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Item status: \(item.status)
                Date: \(Date().second)
            """)
        }
        
        switch item.status {
        case .readyToPlay:
            DispatchQueue.onMain {
                self.delegate?.videoReady(self)
            }
        case .failed:
            DispatchQueue.onMain {
                self.playbackState = .failed((item.error as NSError?).flatMap(PlaybackError.ns) ?? .avPlayerFailed)
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    private func itemPlaybackBufferEmpty(change: NSKeyValueObservedChange<Bool>) {
        guard let item = self.item else { return }
        
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Item isPlaybackBufferEmpty: \(item.isPlaybackBufferEmpty)
                Date: \(Date().second)
            """)
        }
        
        if item.isPlaybackBufferEmpty {
            bufferingState = .delayed
        }
        
        switch item.status {
        case .readyToPlay:
            playerLayer.player = player
            playerLayer.isHidden = false
        case .failed:
            playbackState = .failed(.avPlayerFailed)
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    private func itemKeepUp(change: NSKeyValueObservedChange<Bool>) {
        guard let item = self.item else { return }
        
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Item isPlaybackLikelyToKeepUp: \(item.isPlaybackLikelyToKeepUp), \(item.status)
                Date: \(Date().second)
            """)
        }
        
        if item.isPlaybackLikelyToKeepUp {
            bufferingState = .ready
        }
        
        switch item.status {
        case .readyToPlay:
            playerLayer.player = player
            playerLayer.isHidden = false
            
            if item.isPlaybackLikelyToKeepUp {
                delegate?.videoDidBecomeReadyToPlay(self)
                
                if autoPlay {
                    playFromCurrentTime()
                }
            }
        case .failed:
            playbackState = .failed(.avPlayerFailed)
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    private func itemLoadedTimeRanges(change: NSKeyValueObservedChange<[NSValue]>) {
        guard let item = self.item else { return }
        
        bufferingState = .ready
        
        if let timeRange = item.loadedTimeRanges.first?.timeRangeValue {
            let bufferedTime = (timeRange.start + timeRange.duration).seconds
            DispatchQueue.onMain {
                self.delegate?.videoBufferTimeDidChange(bufferedTime)
            }
        }
    }
    
}

extension AVPlayerItem.Status: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .readyToPlay: return "Ready to play"
        case .failed:      return "Failed"
        case .unknown:     return "Unknown"
        @unknown default:  return "Unknown"
        }
    }
    
}

extension AVPlayer.Status: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .readyToPlay: return "Ready to play"
        case .failed:      return "Failed"
        case .unknown:     return "Unknown"
        @unknown default:  return "Unknown"
        }
    }
    
}

extension CMTime {
    
    init(timeInterval: TimeInterval) {
        self.init(seconds: timeInterval, preferredTimescale: 1000000000)
    }
    
    var seconds: Float64 {
        return CMTimeGetSeconds(self)
    }
    
}

