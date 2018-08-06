//
//  MessageListViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class MessageListViewController: ViewController {
    
    enum Cell {
        case header(String)
        case message(Watermark.Message)
        case smallMessage(Watermark.Message)
        case seriesList([Watermark.Series])
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .header:               return CGSize(width: collectionView.width - .padding * 2, height: 25)
            case .message(let message): return MessageCell.size(forMessage: message, in: collectionView)
            case .smallMessage:         return CGSize(width: collectionView.width - .padding * 2, height: 70)
            case .seriesList:           return CGSize(width: collectionView.width, height: .seriesCellHeight)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    private let collectionView   = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding * 1.5, sectionInset: UIEdgeInsets(top: .padding, bottom: .padding)))
    private let loadingIndicator = LoadingView()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(HeaderCell.self)
            $0.registerCell(MessageCell.self)
            $0.registerCell(SmallMessageCell.self)
            $0.registerCell(SeriesListCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .lightBackground
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinCenterY(to: view)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .grayBlue
            $0.startAnimating()
        }
        
        UIView(superview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top)
            $0.backgroundColor = .lightBackground
        }
        
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
            
            var cells: [Cell] = []
            
            if let message = messages.first {
                cells.append(contentsOf: [
                    .header("Latest Message"),
                    .message(message)
                ])
            }
            
            if !series.isEmpty {
                cells.append(contentsOf: [
                    .header("Series"),
                    .seriesList(series)
                ])
            }
            
            if !messages.dropFirst().isEmpty {
                cells.append(.header("Recent"))
                for message in messages.dropFirst() {
                    cells.append(.smallMessage(message))
                }
            }
            
            self?.cells = cells
            
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.reloadData()
            }
            
            dequeue()
        }
    }
    
}

extension MessageListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .header(let text):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: text)
            return cell
        case .message(let message):
            let cell: MessageCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(message: message)
            return cell
        case .smallMessage(let message):
            let cell: SmallMessageCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(message: message)
            return cell
        case .seriesList(let series):
            let cell: SeriesListCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(series: series)
            return cell
        }
    }
    
}

extension MessageListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = cells.at(indexPath.row) else { return }
        
        switch cell {
        case .message(let message):      MessageViewController(message: message).show()
        case .smallMessage(let message): MessageViewController(message: message).show()
        case .seriesList: break
        case .header: break
        }
    }
    
}
