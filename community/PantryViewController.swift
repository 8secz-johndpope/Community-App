//
//  PantryViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Alexandria

final class PantryViewController: ViewController {
    
    private var shelves: [Contentful.Shelf] = []
    
    private let collectionView = UICollectionView(layout: .vertical(lineSpacing: 0))
    private let shadowView     = ShadowView()
    private let headerView     = UIView()
    private let tableLabel     = UILabel()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        shelves = Contentful.LocalStorage.pantry?.shelves.filter { !$0.postIDs.isEmpty } ?? []
        
        view.backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(ShelfCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .lightBackground
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.contentInset.top = 60
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 60)
            $0.backgroundColor = .clear
        }
        
        shadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.backgroundColor = .white
            $0.shadowOpacity = 0.2
            $0.alpha = 0
        }
        
        UIButton().add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).pinTrailing(to: headerView)
            $0.constrainWidth(to: 60).constrainHeight(to: 60)
            $0.titleLabel?.font = .fontAwesome(.regular, size: 20)
            $0.setTitle(Icon.infoCircle.string, for: .normal)
            $0.setTitleColor(.grayBlue, for: .normal)
            $0.addTarget(for: .touchUpInside) {
                guard let info = Contentful.LocalStorage.pantry?.info else { return }
                UIAlertController.alert(message: info).addAction(title: "OK").present()
            }
        }
        
        tableLabel.add(toSuperview: headerView).customize {
            $0.pinBottom(to: headerView).constrainHeight(to: 60)
            $0.pinCenterX(to: headerView).constrainSize(toFit: .horizontal)
            $0.font = .bold(size: 25)
            $0.textColor = .grayBlue
            $0.text = "The Pantry"
        }
        
        Notifier.onPantryChanged.subscribePast(with: self) { [weak self] in
            self?.shelves = Contentful.LocalStorage.pantry?.shelves.filter { !$0.postIDs.isEmpty } ?? []
            self?.collectionView.reloadData()
        }.onQueue(.main)
    }
    
}

extension PantryViewController: UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.alpha = scrollView.adjustedOffset.y.map(from: 0...20, to: 0...1).limited(0, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ShelfCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(shelf: shelves[indexPath.row])
        return cell
    }
    
}

extension PantryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ShelfViewController(shelf: shelves[indexPath.row]), animated: true)
    }
    
}
