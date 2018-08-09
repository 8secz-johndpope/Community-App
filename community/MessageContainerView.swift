//
//  MessageContainerView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit
import Alexandria

protocol MessageContainerViewDelegate: AnyObject {
    func didSeek(toProgress progress: CGFloat, in view: MessageContainerView)
    func didCommit(toProgress progress: CGFloat, in view: MessageContainerView)
    func didTapPlayPauseButton(in view: MessageContainerView)
}

final class MessageContainerView: ShadowView {
    
    let message: Watermark.Message
    
    var progress: CGFloat = 0 {
        didSet {
            progressView.update(progress: progress)
            progressButtonHolder.centerX = leftProgressOffset + progress * progressView.width
            progressButtonHolder.centerY = progressView.centerY
        }
    }
    
    var bufferProgress: CGFloat = 0 {
        didSet {
            progressView.update(bufferProgress: bufferProgress)
        }
    }
    
    weak var delegate: MessageContainerViewDelegate?
    
    private let playbackInfoView     = UIView()
    private let timeLabel            = UILabel()
    private let playPauseButton      = UIButton()
    private let progressView         = MediaProgressView()
    private let progressButtonHolder = UIView()
    private let progressButton       = UIView()
    private let titleLabel           = UILabel()
    private let subtitleLabel        = UILabel()
    private let descriptionView      = SelfSizingTextView()
    
    private var startingProgress: CGFloat = 0
    private var duration: TimeInterval = 0
    private var isShowingPlaybackControls = true
    private let leftProgressOffset: CGFloat = 70
    
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isShowingPlaybackControls {
            return super.point(inside: point, with: event)
        }
        else {
            if playbackInfoView.frame.contains(point) {
                return false
            }
            return super.point(inside: point, with: event)
        }
    }
    
    required init(message: Watermark.Message) {
        self.message = message
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageContainerView {
    
    func resetProgressButton() {
        progressButtonHolder.center = CGPoint(x: leftProgressOffset, y: progressView.centerY)
    }
    
    func update(isPlaying: Bool) {
        playPauseButton.isSelected = !isPlaying
    }
    
    private func setup() {
        
        backgroundColor = .clear
        shadowOffset = CGSize(width: 0, height: -10)
        
        UIView(superview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: self, .bottom).constrainHeight(to: 500)
            $0.backgroundColor = .lightBackground
        }
        
        UIView(superview: self).customize {
            $0.constrainEdgesToSuperview(top: 50)
            $0.backgroundColor = .lightBackground
        }
        
        playbackInfoView.add(toSuperview: self).customize {
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.pinTop(to: self).constrainHeight(to: 50)
        }
        
        playPauseButton.add(toSuperview: playbackInfoView).customize {
            $0.pinLeading(to: playbackInfoView).constrainWidth(to: 60)
            $0.pinTop(to: playbackInfoView).pinBottom(to: playbackInfoView)
            $0.setTitle(Icon.pause.string, for: .normal)
            $0.setTitle(Icon.play.string, for: .selected)
            $0.setTitleColor(.lightBackground, for: .normal)
            $0.titleLabel?.font = .fontAwesome(.solid, size: 25)
            $0.addTarget(for: .touchUpInside) { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.didTapPlayPauseButton(in: self)
            }
        }
        
        timeLabel.add(toSuperview: playbackInfoView).customize {
            $0.pinTrailing(to: playbackInfoView, plus: -.padding).pinCenterY(to: playbackInfoView)
            $0.constrainWidth(to: 85).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 14)
            $0.textColor = .lightBackground
            $0.textAlignment = .right
            $0.text = "00:00 / 00:00"
        }
        
        progressView.add(toSuperview: playbackInfoView).customize {
            $0.pinLeading(to: playPauseButton, .trailing, plus: 10).pinTrailing(to: timeLabel, .leading, plus: -.padding)
            $0.pinCenterY(to: playbackInfoView)
            $0.isUserInteractionEnabled = false
        }
        
        progressButtonHolder.add(toSuperview: playbackInfoView).customize {
            $0.centerX = leftProgressOffset
            $0.size = CGSize(width: 30, height: 30)
            $0.backgroundColor = .clear
            $0.addGesture(type: .pan) { [weak self] in
                self?.seek(gesture: $0)
            }
        }
        
        progressButton.add(toSuperview: progressButtonHolder).customize {
            $0.frame = CGRect(width: 30, height: 30)
            $0.backgroundColor = .orange
            $0.cornerRadius = 15
            $0.transform = .scale(0.5, 0.5)
            $0.isUserInteractionEnabled = false
        }
        
        titleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: progressView, .bottom, plus: 50).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.font = .bold(size: 20)
            $0.textColor = .dark
            $0.textAlignment = .left
            $0.text = message.title
        }
        
        subtitleLabel.add(toSuperview: self).customize {
            $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
            $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
            $0.numberOfLines = 0
            $0.attributedText = (
                message.speakers.map { $0.name }.joined(separator: ", ").attributed.font(.bold(size: 14)) +
                "   •   \(DateFormatter.readable.string(from: message.date))".attributed.font(.regular(size: 14))
            ).color(.dark)
        }
        
        descriptionView.add(toSuperview: self).customize {
            $0.pinTop(to: subtitleLabel, .bottom)
            $0.pinLeading(to: self).pinTrailing(to: self)
            $0.textContainerInset = UIEdgeInsets(inset: .textInset)
            $0.backgroundColor = .lightBackground
            $0.isEditable = false
            $0.isSelectable = true
            $0.delegate = self
            $0.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.orange]
            $0.attributedText = message.details.attributed
                .color(.dark)
                .font(.regular(size: 14))
                .lineSpacing(5)
        }
        
        if !message.scriptureReferences.isEmpty {
            
            let scriptureReferenceTitleLabel = UILabel(superview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinTop(to: descriptionView, .bottom).constrainSize(toFit: .vertical)
                $0.font = .bold(size: 16)
                $0.textColor = .dark
                $0.text = "Scripture References"
            }
            
            UILabel(superview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinTop(to: scriptureReferenceTitleLabel, .bottom, plus: 10).pinBottom(to: self, plus: -.padding * 2)
                $0.constrainSize(toFit: .vertical)
                $0.font = .bold(size: 14)
                $0.numberOfLines = 0
                $0.textColor = .orange
                $0.text = message.scriptureReferences.map { $0.reference }.joined(separator: ", ")
            }
            
        }
        else {
            descriptionView.pinBottom(to: self, plus: -.padding * 2)
        }
        
    }
    
    func update(currentTime: TimeInterval, duration: TimeInterval) {
        self.duration = duration
        timeLabel.text = "\(Int(currentTime).timeString) / \(Int(duration).timeString)"
    }
    
    func update(isProgressButtonVisible: Bool) {
        if isProgressButtonVisible {
            isShowingPlaybackControls = true
            
            playbackInfoView.alpha = 0
            
            UIView.animate(withDuration: 0.25) {
                self.playbackInfoView.alpha = 1
            }
        }
        else {
            isShowingPlaybackControls = false
            
            UIView.animate(withDuration: 0.25) {
                self.playbackInfoView.alpha = 0
            }
        }
    }
    
    private func seek(gesture: UIGestureRecognizer) {
        guard let gesture = gesture.pan else { return }
        
        if gesture.state == .began {
            startingProgress = progressView.progress
            
            UIView.animate(withDuration: 0.25) {
                self.progressButton.transform = .identity
            }
        }
        
        let translation = gesture.translation(in: self)
        let progressWidth = progressView.width.limited(100, width)
        let progress = (startingProgress + translation.x / progressWidth).limited(0, 1)
        
        if [.ended, .cancelled].contains(gesture.state) {
            UIView.animate(withDuration: 0.25) {
                self.progressButton.transform = .scale(0.5, 0.5)
            }
            
            update(progress: progress)
            delegate?.didCommit(toProgress: progress, in: self)
        }
        else if [.changed].contains(gesture.state) {
            update(progress: progress)
            delegate?.didSeek(toProgress: progress, in: self)
        }
    }
    
    private func update(progress: CGFloat? = nil, buffer: CGFloat? = nil) {
        progressView.update(progress: progress, bufferProgress: buffer)
        progressButtonHolder.centerY = progressView.centerY
        
        if let progress = progress {
            progressButtonHolder.centerX = leftProgressOffset + progress * progressView.width
            
            if duration > 0 {
                timeLabel.text = "\(Int(Double(progress) * duration).timeString) / \(Int(duration).timeString)"
            }
        }
    }
    
}

extension MessageContainerView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIViewController.current?.showInSafari(url: URL)
        return false
    }
    
}
