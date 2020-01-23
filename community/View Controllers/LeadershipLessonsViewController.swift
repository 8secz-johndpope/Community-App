//
//  LeadershipLessonsViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

final class LeadershipLessonsViewController: ViewController, HeaderViewController, ReloadingViewController {
    
    enum Cell {
        case latest(Contentful.Post)
        case toggle
        case episode(Contentful.Post)
        case empty
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .latest:         return CGSize(width: collectionView.width, height: 400)
            case .toggle:         return CGSize(width: collectionView.width - .padding * 2, height: 32)
            case .episode(let e): return EpisodeCell.size(forEpisode: e, in: collectionView)
            case .empty:          return CGSize(width: collectionView.width - .padding * 2, height: 200)
            }
        }
        
        var episode: Contentful.Post? {
            switch self {
            case .latest(let e):  return e
            case .toggle:         return nil
            case .episode(let e): return e
            case .empty:          return nil
            }
        }
    }
    
    private let collectionView  = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(bottom: .padding)))
    private let imageViewHolder = UIStackView()
    
    private var cells: [Cell] {
        switch selection {
        case .latest:   return latestCells
        case .unplayed: return unplayedCells
        }
    }
    
    private var latestCells: [Cell] = []
    private var unplayedCells: [Cell] = []
    private var selection: ToggleCell.Selection = .latest
    
    var scrollView: UIScrollView { collectionView }
    let shadowView  = ShadowView()
    let headerView  = UIView()
    let headerLabel = UILabel()
    let refreshControl = UIRefreshControl()
    
    var isShowingHeaderLabel = false
    
    override func viewDidAppearForFirstTime() {
        super.viewDidAppearForFirstTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.headerView.isHidden = false
        }
    }
    
    override func setup() {
        super.setup()
        
        imageViewHolder.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinSafely(.bottom, to: view, .top, plus: 400)
            $0.spacing = 0
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
        
        (0...1).forEach { index in
            LoadingImageView().add(toStackview: imageViewHolder).customize {
                $0.pinLeading(to: imageViewHolder).pinTrailing(to: imageViewHolder)
                $0.constrainHeight(to: $0, .width)
                $0.image = UIImage(named: "tile3")
                $0.contentMode = .scaleAspectFill
                $0.showDimmer = true
                $0.transform = .rotate(index.isEven ? .pi : 0)
            }
        }
        
        view.backgroundColor = .background
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(LatestEpisodeCell.self)
            $0.registerCell(ToggleCell.self)
            $0.registerCell(EpisodeCell.self)
            $0.registerCell(EmptyStateCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.alwaysBounceVertical = true
        }
        
        refreshControl.add(toSuperview: collectionView).customize {
            $0.addTarget(self, action: #selector(reloadContent), for: .valueChanged)
            $0.tintColor = .white
        }
        
        setupHeader(in: view, title: Contentful.LocalStorage.leadershipLessons?.title)
        
        Notifier.onLeadershipLessonsChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
        
        Notifier.onMediaProgressSaved.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isShowingHeaderLabel ? .default : .lightContent
    }
    
    private func reload() {
        guard
            let leadershipLessons = Contentful.LocalStorage.leadershipLessons,
            let latest = leadershipLessons.latest
        else { return }
        
        headerLabel.text = leadershipLessons.title
        
        latestCells = [.latest(latest), .toggle] + leadershipLessons.recent.map(Cell.episode)
        unplayedCells = [.latest(latest), .toggle] + (leadershipLessons.unplayed.isEmpty ? [.empty] : leadershipLessons.unplayed.map(Cell.episode))
        
        collectionView.reloadData()
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .latest(let episode):
            let cell: LatestEpisodeCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(episode: episode)
            return cell
        case .toggle:
            let cell: ToggleCell = collectionView.dequeueCell(for: indexPath)
            cell.didSelect = { [weak self] selection in
                self?.selection = selection
                self?.collectionView.reloadData()
            }
            return cell
        case .episode(let episode):
            let cell: EpisodeCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(episode: episode)
            return cell
        case .empty:
            let cell: EmptyStateCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: Contentful.LocalStorage.leadershipLessons?.emptyStateMessage ?? "")
            return cell
        }
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageViewHolder.transform = .translate(0, -scrollView.adjustedOffset.y)
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
