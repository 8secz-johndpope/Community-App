//
//  ContentContainerView.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import UIKit
import Alexandria

protocol ContentContainerViewDelegate: AnyObject {
    func didSeek(toProgress progress: CGFloat, in view: ContentContainerView)
    func didCommit(toProgress progress: CGFloat, in view: ContentContainerView)
    func didTapPlayPauseButton(in view: ContentContainerView)
}

final class ContentContainerView: ShadowView {
    
    let content: ContentViewController.Content
    
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
    
    weak var delegate: ContentContainerViewDelegate?
    
    private let playbackInfoView     = UIView()
    private let timeLabel            = UILabel()
    private let playPauseButton      = UIButton()
    private let progressView         = MediaProgressView()
    private let progressButtonHolder = UIView()
    private let progressButton       = UIView()
    private let messageContentView   = MessageContentView()
    private let textPostContentView  = TextPostContentView()
    
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
    
    required init(content: ContentViewController.Content) {
        self.content = content
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ContentContainerView {
    
    func resetProgressButton() {
        progressButtonHolder.center = CGPoint(x: leftProgressOffset, y: progressView.centerY)
    }
    
    func update(isPlaying: Bool) {
        playPauseButton.isSelected = !isPlaying
    }
    
    private func setup() {
        
        backgroundColor = .clear
        shadowOffset = CGSize(width: 0, height: 50)
        
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
                guard let self = self else { return }
                self.delegate?.didTapPlayPauseButton(in: self)
            }
        }
        
        timeLabel.add(toSuperview: playbackInfoView).customize {
            $0.pinTrailing(to: playbackInfoView, plus: -.padding).pinCenterY(to: playbackInfoView)
            $0.constrainWidth(to: 85).constrainSize(toFit: .vertical)
            $0.font = .regular(size: 14)
            $0.textColor = .lightBackground
            $0.textAlignment = .right
            $0.text = "0:00 / 0:00"
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
        
        switch content {
        case .message(let message):
            messageContentView.add(toSuperview: self).customize {
                $0.pinTop(to: playPauseButton, .bottom).pinBottom(to: self)
                $0.pinLeading(to: self).pinTrailing(to: self)
                $0.configure(message: message)
            }
        case .textPost(let post):
            textPostContentView.add(toSuperview: self).customize {
                $0.pinTop(to: playPauseButton, .bottom).pinBottom(to: self)
                $0.pinLeading(to: self).pinTrailing(to: self)
                $0.configure(textPost: post)
            }
            
            update(isPlaying: false)
            
            if post.mediaURL == nil {
                playbackInfoView.isHidden = true
            }
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

extension ContentContainerView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIViewController.current?.showInSafari(url: URL)
        return false
    }
    
}

final class ScriptureReferenceCollectionView: SelfSizingCollectionView {
    
    private var references: [String] = []
    
    required init() {
        super.init(
            frame: .zero,
            collectionViewLayout: LeftAlignedCollectionViewLayout().customize {
                $0.minimumLineSpacing = 0
                $0.minimumInteritemSpacing = 0
            }
        )
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(references: [String]) {
        self.references = references
        self.reloadData()
    }
    
    private func setup() {
        customize {
            $0.backgroundColor = .lightBackground
            $0.registerCell(ScriptureReferenceCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
        }
    }
    
}

extension ScriptureReferenceCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return references.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ScriptureReferenceCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(reference: references[indexPath.row], includeComma: indexPath.row != references.count - 1)
        return cell
    }
    
}

extension ScriptureReferenceCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ScriptureReferenceCell.size(
            forReference: references[indexPath.row],
            includeComma: indexPath.row != references.count - 1,
            in: collectionView
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ScriptureReferenceCell,
            let reference = cell.reference?.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
            !reference.isEmpty
        else { return }
        
        let url = URL(string: "https://www.biblegateway.com/passage/?search=\(reference)&version=ESV")
        UIViewController.current?.showInSafari(url: url)
    }
    
}

final class ScriptureReferenceCell: CollectionViewCell {
    
    private(set) var reference: String?
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        label.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.textColor = .orange
            $0.font = .bold(size: 14)
            $0.backgroundColor = .lightBackground
        }
    }
    
    func configure(reference: String, includeComma: Bool) {
        self.reference = reference
        label.text = includeComma ? "\(reference), " : reference
        contentView.backgroundColor = .random
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reference = nil
        label.text = nil
    }
    
    static func size(forReference reference: String, includeComma: Bool, in collectionView: UICollectionView) -> CGSize {
        let string = includeComma ? "\(reference), " : reference
        let size = string.size(font: .bold(size: 14))
        
        return CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
    }
    
}
