//
//  AudioPlayer.swift
//  community
//
//  Created by Jonathan Landon on 1/26/19.
//

import Foundation
import AVFoundation
import UIKit
import AVKit
import MediaPlayer

// MARK: - PlayerDelegate

/// Player delegate protocol
protocol AudioPlayerDelegate: AnyObject {
    func playerReady(_ player: AudioPlayer)
    func playerPlaybackStateDidChange(_ player: AudioPlayer)
    func playerBufferingStateDidChange(_ player: AudioPlayer)
    func playerBufferTimeDidChange(_ bufferTime: Double)
    func playerDidBecomeReadyToPlay(_ player: AudioPlayer)
}


/// Player playback protocol
protocol AudioPlayerPlaybackDelegate: AnyObject {
    func playerCurrentTimeDidChange(_ player: AudioPlayer)
    func playerPlaybackWillStartFromBeginning(_ player: AudioPlayer)
    func playerPlaybackDidEnd(_ player: AudioPlayer)
    func playerPlaybackWillLoop(_ player: AudioPlayer)
}

final class AudioPlayer: NSObject {
    
    private let isLoggingEnabled = false
    
    private var playerRateObserver: NSKeyValueObservation?
    private var playerStatusObserver: NSKeyValueObservation?
    
    private var itemStatusObserver: NSKeyValueObservation?
    private var itemEmptyBufferObserver: NSKeyValueObservation?
    private var itemKeepUpObserver: NSKeyValueObservation?
    private var itemLoadedTimeRangesObserver: NSKeyValueObservation?
    
    override init() {
        super.init()
        player = AVPlayer()
        player?.actionAtItemEnd = .pause
        timeObserver = nil
    }
    
    deinit {
        player?.pause()
        
        printAccessLog()
        
        setup(item: nil)
        
        removePlayerObservers()
        
        delegate = nil
        removeApplicationObservers()
        
        playbackDelegate = nil
        
        player = nil
    }
    
    var durationWatched: TimeInterval {
        return (item?.accessLog()?.events.reduce(0) { $0 + $1.durationWatched } ?? 0).limited(0, duration).rounded(.up)
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
                Duration watched: \(event.durationWatched)
                Number of stalls: \(event.numberOfStalls)
                Playback type: \(event.playbackType ?? "null")
                Startup time: \(event.startupTime)
                Download overdue: \(event.downloadOverdue)
                Indicated average bitrate: \(event.indicatedAverageBitrate)
                Indicated bitrate: \(event.indicatedBitrate)
                Observed bitrate: \(event.observedBitrate)
                Number of bytes transferred: \(event.numberOfBytesTransferred)
                Number of media requests: \(event.numberOfMediaRequests)
                Playback session ID: \(event.playbackSessionID ?? "null")
                Switch bitrate: \(event.switchBitrate)
                
                -------------------------------------------------------
                """)
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: AudioPlayerDelegate?
    weak var playbackDelegate: AudioPlayerPlaybackDelegate?
    
    var autoPlay = true
    
    var isPlaying: Bool {
        return playbackState == .playing
    }
    
    private var player: AVPlayer?
    private var asset: AVAsset?
    private var item: AVPlayerItem?
    private var timeObserver: Any?
    private var seekTimeRequested: TimeInterval?
    
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
                DispatchQueue.onMain { self.delegate?.playerPlaybackStateDidChange(self) }
            }
        }
    }
    
    /// Current buffering state of the Player.
    var bufferingState: BufferingState = .unknown {
        didSet {
            if bufferingState != oldValue {
                self.delegate?.playerBufferingStateDidChange(self)
            }
        }
    }
    
    /// Media playback's current time.
    var currentTime: TimeInterval {
        guard let item = item else { return 0 }
        return item.currentTime().seconds
    }
    
    /// Media plaback's duration.
    var duration: TimeInterval {
        guard let item = item else { return 0 }
        return item.duration.seconds
    }
    
    var progress: CGFloat {
        guard currentTime >= 0, duration > 0 else { return 0 }
        return CGFloat(currentTime / duration)
    }
    
}

extension AudioPlayer {
    
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
    
    enum PlaybackError: Swift.Error {
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

extension AudioPlayer {
    
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
        
        removePlayerObservers()
        removeApplicationObservers()
        
        if let url = url {
            let asset = AVURLAsset(url: url)
            setup(asset: asset)
        }
        
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
    
    fileprivate func setup(item: AVPlayerItem?) {
        
        removeItemObservers()
        
        self.item = item
        
        if let seek = seekTimeRequested, self.item != nil {
            seekTimeRequested = nil
            self.seek(to: seek)
        }
        
        addItemObservers()
        
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

extension AudioPlayer {
    
    /// Stops media and seeks to the beginning.
    func reset() {
        stop()
        player?.seek(to: .zero)
    }
    
    /// Begins playback of the media from the beginning.
    func playFromBeginning() {
        playbackDelegate?.playerPlaybackWillStartFromBeginning(self)
        player?.seek(to: .zero)
        playFromCurrentTime()
    }
    
    /// Begins playback of the media from the current time.
    func playFromCurrentTime() {
        playbackState = .playing
        player?.play()
    }
    
    /// Pauses playback of the media.
    func pause() {
        if playbackState != .playing {
            return
        }
        
        player?.pause()
        playbackState = .paused
    }
    
    /// Stops playback of the media.
    func stop() {
        if playbackState == .stopped {
            return
        }
        
        player?.pause()
        playbackState = .stopped
        playbackDelegate?.playerPlaybackDidEnd(self)
    }
    
    /// Updates playback to the specified time.
    ///
    /// - Parameter time: The time to switch to move the playback.
    func seek(to time: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        if let playerItem = item {
            let timescale = playerItem.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(time, preferredTimescale: timescale)
            guard ![.invalid, .indefinite, .positiveInfinity, .negativeInfinity].contains(time) else { return }
            playerItem.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completion)
        }
        else {
            seekTimeRequested = time
        }
    }
    
    func goBack(seconds: TimeInterval) {
        seek(to: (currentTime - seconds).limited(0, .greatestFiniteMagnitude))
    }
    
    func goForward(seconds: TimeInterval, max: TimeInterval? = nil) {
        seek(to: (currentTime + seconds).limited(0, max ?? duration))
    }
    
}

// MARK: - NSNotifications

extension AudioPlayer {
    
    // MARK: AVPlayerItem
    
    @objc private func playerItemDidPlayToEndTime(_ aNotification: Notification) {
        if playbackLoops {
            playbackDelegate?.playerPlaybackWillLoop(self)
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
    
    @objc private func playerItemFailedToPlayToEndTime(_ aNotification: Notification) {
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

// MARK: - UIApplication

extension AudioPlayer {
    
    private func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    private func removeApplicationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - handlers
    
    @objc private func handleApplicationWillResignActive(_ notification: Notification) {
        
    }
    
    @objc private func handleApplicationDidEnterBackground(_ notification: Notification) {
        
    }
    
    @objc private func handleApplicationWillEnterForeground(_ notification: Notification) {
        
    }
    
    @objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
        
    }
    
}

// MARK: - Observer setup

extension AudioPlayer {
    
    // MARK: AVPlayerObservers
    
    private func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 100), queue: .main) { [weak self] timeInterval in
            guard let `self` = self else { return }
            self.playbackDelegate?.playerCurrentTimeDidChange(self)
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

extension AudioPlayer {
    
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
        if isLoggingEnabled {
            print("""
                --------------------------------------------------
                Player status: \(player?.status ?? .unknown)
                Date: \(Date().second)
                """)
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
                self.delegate?.playerReady(self)
            }
        case .failed:
            playbackState = .failed((item.error as NSError?).flatMap(PlaybackError.ns) ?? .avPlayerFailed)
        case .unknown:
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
            break
        case .failed:
            playbackState = .failed(.avPlayerFailed)
        case .unknown:
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
            if item.isPlaybackLikelyToKeepUp {
                delegate?.playerDidBecomeReadyToPlay(self)
            }
        case .failed:
            playbackState = .failed(.avPlayerFailed)
        case .unknown:
            break
        }
    }
    
    private func itemLoadedTimeRanges(change: NSKeyValueObservedChange<[NSValue]>) {
        guard let item = self.item else { return }
        
        bufferingState = .ready
        
        if let timeRange = item.loadedTimeRanges.first?.timeRangeValue {
            let bufferedTime = (timeRange.start + timeRange.duration).seconds
            DispatchQueue.onMain {
                self.delegate?.playerBufferTimeDidChange(bufferedTime)
            }
        }
        else if autoPlay {
            playFromCurrentTime()
        }
    }
    
}
