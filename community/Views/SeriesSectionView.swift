//
//  SeriesSectionView.swift
//  community
//
//  Created by Jonathan Landon on 8/2/18.
//

import UIKit
import Diakoneo

final class SeriesSectionView: View {
    
    private var series: [Watermark.Series] = []
    
    private let collectionView = UICollectionView(layout: .horizontal(lineSpacing: .padding, sectionInset: UIEdgeInsets(left: .padding, right: .padding)))
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.constrainHeight(to: .seriesCellHeight)
            $0.registerCell(SeriesCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .lightBackground
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.clipsToBounds = false
        }
    }
    
    func configure(series: [Watermark.Series]) {
        self.series = series
        self.collectionView.reloadData()
    }
    
}

extension SeriesSectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return series.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SeriesCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(series: series[indexPath.row])
        return cell
    }
    
}

extension SeriesSectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .seriesSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let series = self.series.at(indexPath.row) else { return }
        SeriesViewController(series: series).show()
    }
    
}
