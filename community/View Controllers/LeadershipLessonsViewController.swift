//
//  LeadershipLessonsViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

final class LeadershipLessonsViewController: ViewController, HeaderViewController {
    
    enum Cell {
        case latest(Contentful.Post)
        case toggle
        case episode(Contentful.Post)
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .latest:         return CGSize(width: collectionView.width, height: 400)
            case .toggle:         return CGSize(width: collectionView.width - .padding * 2, height: 32)
            case .episode(let e): return EpisodeCell.size(forEpisode: e, in: collectionView)
            }
        }
        
        var episode: Contentful.Post? {
            switch self {
            case .latest(let e):  return e
            case .toggle:         return nil
            case .episode(let e): return e
            }
        }
    }
    
    private let collectionView = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(bottom: .padding)))
    private let imageView      = LoadingImageView()
    private let refreshControl = UIRefreshControl()
    
    private var cells: [Cell] = []
    
    var scrollView: UIScrollView { collectionView }
    let shadowView  = ShadowView()
    let headerView  = UIView()
    let headerLabel = UILabel()
    
    var isShowingHeaderLabel = false
    
    override func viewDidAppearForFirstTime() {
        super.viewDidAppearForFirstTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.headerView.isHidden = false
        }
    }
    
    override func setup() {
        super.setup()
        
        imageView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: 400)
            $0.image = UIImage(named: "tile3")
            $0.contentMode = .scaleAspectFill
            $0.showDimmer = true
        }
        
        view.backgroundColor = .background
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(LatestEpisodeCell.self)
            $0.registerCell(ToggleCell.self)
            $0.registerCell(EpisodeCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
        }
        
        refreshControl.add(toSuperview: collectionView).customize {
            $0.addTarget(self, action: #selector(reloadContent), for: .valueChanged)
            $0.tintColor = .text
        }
        
        setupHeader(in: view, title: Contentful.LocalStorage.leadershipLessons?.title)
        
        Notifier.onLeadershipLessonsChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isShowingHeaderLabel ? .default : .lightContent
    }
    
    private func reload() {
        guard let leadershipLessons = Contentful.LocalStorage.leadershipLessons else { return }
        
        headerLabel.text = leadershipLessons.title
        
        cells = [.latest(leadershipLessons.episodes[0]), .toggle] + Array(leadershipLessons.episodes.dropFirst()).map(Cell.episode)
        collectionView.reloadData()
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .latest(let episode):
            let cell: LatestEpisodeCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(episode: episode)
            return cell
        case .toggle:
            let cell: ToggleCell = collectionView.dequeueCell(for: indexPath)
            cell.didSelect = { selection in
                print("Selected: \(selection)")
            }
            return cell
        case .episode(let episode):
            let cell: EpisodeCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(episode: episode)
            return cell
        }
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageView.transform = .translate(0, -scrollView.adjustedOffset.y)//.limited(0, .greatestFiniteMagnitude))
        didScroll()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = cells.at(indexPath.row)?.episode else { return }
        episode.show(from: .table)
    }
    
}
