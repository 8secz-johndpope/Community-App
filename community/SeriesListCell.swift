//
//  SeriesListCell.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Alexandria

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let series = self.series.at(indexPath.row) else { return }
        SeriesViewController(series: series).show()
    }
    
}
