//
//  MessageListViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Nuke

extension UIColor {
    var isLightColor: Bool {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let colorBrightness = ((r * 299) + (g * 587) + (b * 114)) / 1000
        
        return !(colorBrightness < 0.5)
    }
}

final class MessageListViewController: ViewController, StatusBarViewController {
    
    private var series: [Watermark.Series] = []
    private var messages: [Watermark.Message] = []
    
    var showStatusBarBackground = false {
        didSet {
            updateStatusBarBackground()
        }
    }
    
    var additionalContainerOffset: CGFloat {
        return 60
    }
    
    let scrollView          = UIScrollView()
    let statusBarBackground = ShadowView()
    
    private let backgroundView   = UIView()
    private let containerView    = StackView(axis: .vertical)
    private let loadingIndicator = LoadingView()
    private let refreshControl   = UIRefreshControl()
    
    private let latestMessageView = MessageCellView()
    private let seriesSectionView = SeriesSectionView()
    
    private var statusBarStyle: UIStatusBarStyle = .lightContent
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return showStatusBarBackground ? .default : statusBarStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.delegate = self
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .lightBackground
        
        backgroundView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .loading
        }
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.bottom = .padding
        }
        
        refreshControl.add(toSuperview: scrollView).customize {
            $0.addTarget(self, action: #selector(reload), for: .valueChanged)
            $0.tintColor = .lightBackground
        }
        
        let latestMessageCellHeight = (view.width - .padding * 2) * 9/16 + 64
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
            $0.configure(elements: [
                .view(.clear, 60),
                .custom(header(text: "Messages".attributed.font(.extraBold(size: 35)).color(.lightBackground), backgroundColor: .clear).view),
                .view(.clear, .padding),
                .view(.clear, latestMessageCellHeight),
                .view(.clear, .padding),
            ])
        }
        
        UIView().add(toSuperview: containerView, at: 0).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .lightBackground
        }
        
        statusBarBackground.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 50)
            $0.backgroundColor = .white
            $0.shadowOpacity = 0.1
            $0.alpha = 0
        }
        
        UILabel(superview: statusBarBackground).customize {
            $0.pinBottom(to: statusBarBackground).pinCenterX(to: statusBarBackground)
            $0.constrainHeight(to: 50).constrainSize(toFit: .horizontal)
            $0.font = .bold(size: 16)
            $0.textColor = .dark
            $0.text = "Messages"
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinSafely(.top, to: view, plus: 60 + 35 + .padding + latestMessageCellHeight/2 - 15)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .grayBlue
            $0.startAnimating()
        }
        
        fetchContent()
    }
    
    @objc dynamic private func reload() {
        backgroundView.backgroundColor = .loading
        fetchContent()
    }
    
    func fetchContent() {
        
        let processor = SimpleSerialProcessor()
        
        var series: [Watermark.Series] = []
        
        processor.enqueue { dequeue in
            Watermark.API.Series.fetch(tag: .sunday) { result in
                series = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { dequeue in
            Watermark.API.Series.fetch(tag: .porch) { result in
                series.append(contentsOf: result.value ?? [])
                series.sort(by: { $0.latestDate > $1.latestDate })
                dequeue()
            }
        }
        
        var messages: [Watermark.Message] = []
        
        processor.enqueue { dequeue in
            Watermark.API.Messages.fetch { result in
                messages = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { [weak self] dequeue in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                var seriesIndex: Int?
                
                let messageHeader = self.header(text: "Messages".attributed.font(.extraBold(size: 35)).color(.lightBackground), backgroundColor: .clear)
                
                var elements: [StackView.Element] = [
                    .view(.clear, 60),
                    .custom(messageHeader.view),
                    .view(.clear, .padding),
                ]
                
                if let message = messages.at(0) {
                    
                    if let url = message.image?.url {
                        ImagePipeline.shared.loadImage(with: url, completion: { [weak self] response, error in
                            if let image = response?.image {
                                image.getColors { colors in
                                    
                                    self?.statusBarStyle = colors.background.isLightColor ? .default : .lightContent
                                    
                                    UIView.animate(withDuration: 0.25) {
                                        self?.backgroundView.backgroundColor = colors.background
                                        self?.setNeedsStatusBarAppearanceUpdate()
                                    }
                                    
                                    UIView.transition(with: messageHeader.label, duration: 0.25, options: .transitionCrossDissolve, animations: {
                                        messageHeader.label.textColor = colors.background.isLightColor ? .dark : .lightBackground
                                        self?.refreshControl.tintColor = colors.background.isLightColor ? .dark : .lightBackground
                                    }, completion: nil)
                                }
                            }
                        })
                    }
                    
                    self.latestMessageView.configure(message: message)
                    self.latestMessageView.addGesture(type: .tap) { [weak self] _ in self?.tapped(message: message) }
                    elements.append(contentsOf: [
                        .customPadding(self.latestMessageView, .padding),
                        .view(.clear, .padding)
                    ])
                }
                
                if !series.isEmpty {
                    self.seriesSectionView.configure(series: series)
                    
                    elements.append(contentsOf: [
                        .view(.lightBackground, .padding),
                        .custom(self.header(text: "Series".attributed.font(.extraBold(size: 20)).color(.dark), backgroundColor: .lightBackground).view),
                        .view(.lightBackground, .padding),
                        .custom(self.seriesSectionView),
                    ])
                    
                    seriesIndex = elements.count - 1
                }

                if messages.count > 1 {
                    elements.append(contentsOf: [
                        .view(.lightBackground, .padding),
                        .custom(self.header(text: "Recent".attributed.font(.extraBold(size: 20)).color(.dark), backgroundColor: .lightBackground).view),
                    ])
                }
                
                for message in messages.dropFirst().prefix(10) {
                    let view = SmallMessageCellView()
                    view.configure(message: message)
                    view.addGesture(type: .tap) { [weak self] _ in self?.tapped(message: message) }
                    elements.append(contentsOf: [
                        .view(.lightBackground, .padding),
                        .custom(view)
                    ])
                }
                
                let addedElements = self.containerView.configure(elements: elements)
                
                if let index = seriesIndex, let element = addedElements.at(index) {
                    self.containerView.stackView.bringSubviewToFront(element)
                }
            }
            
            dequeue()
        }
    }
    
    private func header(text: NSAttributedString, backgroundColor: UIColor) -> (view: UIView, label: UILabel) {
        let view = UIView().customize {
            $0.backgroundColor = backgroundColor
        }
        
        let label = UILabel(superview: view).customize {
            $0.pinTop(to: view).pinBottom(to: view)
            $0.pinLeading(to: view, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
            $0.attributedText = text
            $0.backgroundColor = backgroundColor
        }
        
        return (view, label)
    }
    
    func tapped(message: Watermark.Message) {
        MessageViewController(message: message).show()
    }
    
}

extension MessageListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        check(containerView: containerView, in: self)
    }
    
}
