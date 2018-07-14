//
//  HomeViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

final class HomeViewController: ViewController {
    
    enum Cell {
        case header(String)
        case post(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .header:  return CGSize(width: collectionView.width - .padding * 2, height: 25)
            case .post:    return CGSize(width: collectionView.width - .padding * 2, height: collectionView.width * 9/16)
            }
        }
    }
    
    private var cells: [Cell] = []
    
    private let collectionView = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding * 1.5, sectionInset: UIEdgeInsets(inset: .padding)))
    
    override func setup() {
        super.setup()
        
        generateCells()
        
        view.backgroundColor = .white
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(HeaderCell.self)
            $0.registerCell(TablePostCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .white
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
        }
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.generateCells()
            self?.collectionView.reloadData()
        }.onQueue(.main)
    }
    
    private func generateCells() {
        cells.removeAll()
        cells.append(.header("The Table"))
        cells.append(contentsOf: Contentful.LocalStorage.tablePosts.map(Cell.post))
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .header(let text):
            let cell: HeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: text)
            return cell
        case .post(let post):
            let cell: TablePostCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(post: post)
            return cell
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
}

final class HeaderCell: CollectionViewCell {
    
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        label.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.textColor = .dark
            $0.font = .extraBold(size: 20)
        }
    }
    
    func configure(text: String) {
        label.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
}

final class TablePostCell: CollectionViewCell {
    
    private let containerView = ContainerShadowView()
    private let imageView     = LoadingImageView()
    private let label         = UILabel()
    
    override func setup() {
        super.setup()
        
        contentView.clipsToBounds = false
        
        containerView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.backgroundColor = .white
            $0.containerCornerRadius = 3
        }
        
        imageView.add(toSuperview: containerView.container).customize {
            $0.constrainEdgesToSuperview()
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.clipsToBounds = true
        }
        
        label.add(toSuperview: containerView.container).customize {
            $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
            $0.pinCenterY(to: containerView.container).constrainSize(toFit: .vertical)
            $0.font = .bold(size: 20)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
    func configure(post: Contentful.Post) {
        label.text = post.title
        
//        if let image = message.wideImage {
//            imageView.isHidden = false
//            imageView.load(url: image.url)
//        }
//        else {
//            imageView.isHidden = true
//        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
        
        imageView.cancel()
        imageView.isHidden = true
    }
    
}

final class SeriesListCell: CollectionViewCell {
    
    private var series: [Watermark.Series] = []
    
    private let collectionView = UICollectionView(layout: CarouselFlowLayout.seriesContent)
    
    override func setup() {
        super.setup()
        
        collectionView.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(SeriesCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = UIScrollViewDecelerationRateFast
            $0.clipsToBounds = false
        }
    }
    
    func configure(series: [Watermark.Series]) {
        self.series = series
        self.collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        series = []
        collectionView.reloadData()
    }
    
}

extension SeriesListCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return series.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SeriesCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(series: series[indexPath.row])
        return cell
    }
    
}

extension SeriesListCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
}
