//
//  MessageListViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class MessageListViewController: ViewController {
    
    private var series: [Watermark.Series] = []
    private var messages: [Watermark.Message] = []
    
    private let scrollView       = UIScrollView()
    private let containerView    = StackView(axis: .vertical)
    private let loadingIndicator = LoadingView()
    
    private let latestMessageView = MessageCellView()
    private let seriesSectionView = SeriesSectionView()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .lightBackground
        
        GradientView(gradient: .messages, direction: .descending).add(toSuperview: view).constrainEdgesToSuperview()
        
        scrollView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
        }
        
        containerView.add(toSuperview: scrollView).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainWidth(to: scrollView)
            $0.backgroundColor = .clear
        }
        
        UIView().add(toSuperview: containerView, at: 0).customize {
            $0.pinLeading(to: containerView).pinTrailing(to: containerView)
            $0.pinTop(to: containerView, .bottom).constrainHeight(to: view.height)
            $0.backgroundColor = .lightBackground
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinCenterY(to: view)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .grayBlue
            $0.startAnimating()
        }
        
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
        
        func header(text: NSAttributedString, backgroundColor: UIColor) -> UIView {
            let view = UIView().customize {
                $0.backgroundColor = backgroundColor
            }
            
            UILabel(superview: view).customize {
                $0.pinTop(to: view).pinBottom(to: view)
                $0.pinLeading(to: view, plus: .padding).constrainSize(toFit: .vertical, .horizontal)
                $0.attributedText = text
                $0.backgroundColor = backgroundColor
            }
            
            return view
        }
        
        processor.enqueue { [weak self] dequeue in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                
                self.loadingIndicator.stopAnimating()
                
                var seriesIndex: Int?
                
                var elements: [StackView.Element] = [
                    .view(.clear, 60),
                    .custom(header(text: "Messages".attributed.font(.extraBold(size: 35)).color(.lightBackground), backgroundColor: .clear)),
                    .view(.clear, .padding),
                ]
                
                if let message = messages.first {
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
                        .custom(header(text: "Series".attributed.font(.extraBold(size: 20)).color(.dark), backgroundColor: .lightBackground)),
                        .view(.lightBackground, .padding),
                        .custom(self.seriesSectionView),
                    ])
                    
                    seriesIndex = elements.count - 1
                }
                
                if messages.count > 1 {
                    elements.append(contentsOf: [
                        .view(.lightBackground, .padding),
                        .custom(header(text: "Recent".attributed.font(.extraBold(size: 20)).color(.dark), backgroundColor: .lightBackground)),
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
                    self.containerView.stackView.bringSubview(toFront: element)
                }
            }
            
            dequeue()
        }
    }
    
    func tapped(message: Watermark.Message) {
        MessageViewController(message: message).show()
    }
    
}
