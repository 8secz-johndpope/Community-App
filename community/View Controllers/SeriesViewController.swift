//
//  SeriesViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/31/18.
//

import UIKit
import Diakoneo
import Nuke

final class SeriesViewController: ViewController, StatusBarViewController {
    
    private let series: Watermark.Series
    private var messages: [Watermark.Message] = []
    
    var scrollView: UIScrollView {
        return collectionView
    }
    
    var showStatusBarBackground = false {
        didSet {
            updateStatusBarBackground()
            
            if showStatusBarBackground {
                closeButton.configure(normal: .text, highlighted: .black)
            }
            else {
                closeButton.configure(normal: closeButtonColors.normal, highlighted: closeButtonColors.highlighted)
            }
        }
    }
    
    override var pullToDismissOffset: CGFloat {
        return 80
    }
    
    let statusBarBackground = ShadowView()
    
    private let collectionView  = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(top: .padding, bottom: .padding)))
    private let backgroundView  = UIView()
    private let imageShadowView = ContainerShadowView()
    private let imageView       = LoadingImageView()
    private let closeButton     = CloseButton()
    private let titleLabel      = MarqueeLabel(frame: .zero, rate: 15, fadeLength: 10, trailingBuffer: 20)
    private let loadingView     = LoadingView()
    
    private var statusBarStyle: UIStatusBarStyle = .lightContent
    private var closeButtonColors: (normal: UIColor, highlighted: UIColor) = (.background, .backgroundAlt)
    
    private var topOffset: CGFloat {
        let imageHeight = (view.width - .padding * 2) * 9/16
        return imageHeight + 50 + .padding
    }
    
    private var backgroundViewConstraint: NSLayoutConstraint?
    
    required init(series: Watermark.Series) {
        self.series = series
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .background
        
        backgroundView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view)
            $0.backgroundColor = .loading
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
            
            backgroundViewConstraint = $0.constrainSafely(.bottom, to: view, .top, plus: topOffset)
            
            if let url = series.image?.url {
                ImagePipeline.shared.loadImage(with: url, completion: { result in
                    if let image = result.value?.image {
                        image.getColors { [weak self] colors in
                            guard let self = self else { return }
                            
                            let isLightColor = colors.background.isLightColor
                            
                            if #available(iOS 13, *) {
                                self.statusBarStyle = isLightColor ? .darkContent : .lightContent
                            }
                            else {
                                self.statusBarStyle = isLightColor ? .default : .lightContent
                            }
                            
                            self.closeButtonColors = isLightColor ? (.black, .black) : (.white, .white)
                            
                            UIView.animate(withDuration: 0.25) {
                                self.closeButton.configure(normal: self.closeButtonColors.normal, highlighted: self.closeButtonColors.highlighted)
                                self.backgroundView.backgroundColor = colors.background
                                self.setNeedsStatusBarAppearanceUpdate()
                            }
                        }
                    }
                })
            }
        }
        
        imageShadowView.add(toSuperview: backgroundView).customize {
            $0.pinLeading(to: backgroundView, plus: .padding).pinTrailing(to: backgroundView, plus: -.padding)
            $0.pinBottom(to: backgroundView, plus: -.padding).constrainHeight(to: $0, .width, times: 9/16)
            $0.containerCornerRadius = 8
            $0.backgroundColor = .loading
        }
        
        imageView.add(toSuperview: imageShadowView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.load(url: series.image?.url)
            $0.defaultGradient = .empty
            $0.backgroundColor = .backgroundAlt
        }
        
        collectionView.add(toSuperview: view, behind: backgroundView).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(SeriesMessageCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .background
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = topOffset
            $0.panGestureRecognizer.addTarget(self, action: #selector(userDidPan))
        }
        
        statusBarBackground.add(toSuperview: view).customize {
            $0.pinTop(to: view).pinBottomToTopSafeArea(in: self, plus: 50)
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.backgroundColor = .background
            $0.alpha = 0
        }
        
        UIView(superview: statusBarBackground).customize {
            $0.pinLeading(to: statusBarBackground).pinTrailing(to: statusBarBackground)
            $0.pinBottom(to: statusBarBackground).constrainHeight(to: 1)
            $0.backgroundColor = .tabBarLine
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
            $0.textColor = .text
            $0.textAlignment = .left
            $0.text = series.title
            $0.isUserInteractionEnabled = true
            $0.addGesture(type: .tap) { [weak self] _ in self?.scrollView.setContentOffset(x: 0, y: 0) }
        }
        
        loadingView.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinCenterY(to: view)
            $0.constrainWidth(to: 20).constrainHeight(to: 20)
            $0.color = .text
            $0.startAnimating()
        }
        
        Watermark.API.Messages.fetch(series: series) { result in
            DispatchQueue.main.async {
                self.messages = result.value?.collection ?? []
                self.collectionView.reloadData()
                self.loadingView.stopAnimating()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return showStatusBarBackground ? .default : statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}

extension SeriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SeriesMessageCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(message: messages[indexPath.row])
        return cell
    }
    
}

extension SeriesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showStatusBarBackground = (scrollView.adjustedOffset.y - topOffset + additionalContainerOffset > -view.safeInsets.top)
        
        if self.showStatusBarBackground != showStatusBarBackground {
            self.showStatusBarBackground = showStatusBarBackground
        }
        
        imageShadowView.transform = .translate(0, scrollView.adjustedOffset.y * 0.2)
        backgroundViewConstraint?.constant = (topOffset - scrollView.adjustedOffset.y).limited(0, .greatestFiniteMagnitude)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SeriesMessageCell.size(forMessage: messages[indexPath.row], in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let message = messages.at(indexPath.row) else { return }
        ContentViewController(message: message).show()
    }
    
}
