//
//  LeadershipLessonsViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

protocol LatestEpisodeViewDelegate: class {
    func didSelect(episode: Contentful.Post, in view: LeadershipLessonsViewController.LatestEpisodeView)
    func didDetermine(color: UIColor, in view: LeadershipLessonsViewController.LatestEpisodeView)
}

final class LeadershipLessonsViewController: ViewController {
    
    private let collectionView = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(top: UIScreen.main.height * 0.62 - 80, bottom: .padding)))
    private let latestEpisodeView = LatestEpisodeView()
    
    private var episodes: [Contentful.Post] = []
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .black
        
        latestEpisodeView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view)
            $0.delegate = self
        }
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(Cell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
        }
        
        Notifier.onContentLoaded.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func reload() {
        guard let shelf = Contentful.LocalStorage.shelves.first(where: { $0.name == "Leadership Lessons" }) else { return }
        
        let latest = shelf.posts[0]
        latestEpisodeView.configure(episode: latest)
        episodes = Array(shelf.posts.dropFirst())
        
        collectionView.reloadData()
    }
    
}

extension LeadershipLessonsViewController: LatestEpisodeViewDelegate {
    
    func didSelect(episode: Contentful.Post, in view: LeadershipLessonsViewController.LatestEpisodeView) {
        episode.show(from: .table)
    }
    
    func didDetermine(color: UIColor, in view: LeadershipLessonsViewController.LatestEpisodeView) {
        self.view.backgroundColor = color
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(guide: episodes[indexPath.row])
        return cell
    }
    
}

extension LeadershipLessonsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        latestEpisodeView.transform = .translate(0, -(scrollView.adjustedOffset.y * 0.2).limited(0, .greatestFiniteMagnitude))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Cell.size(forEpisode: episodes[indexPath.row], in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = episodes.at(indexPath.row) else { return }
        episode.show(from: .table)
    }
    
}

extension LeadershipLessonsViewController {
    
    final class Cell: CollectionViewCell {
        
        private let titleLabel    = UILabel()
        private let speakersLabel = UILabel()
        private let dateLabel     = UILabel()
        
        override func setup() {
            super.setup()
            
            contentView.backgroundColor = .background
            cornerRadius = 8
            borderColor = .separator
            borderWidth = 1
            
            titleLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinTop(to: contentView, plus: .padding).constrainSize(toFit: .vertical)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 22)
                $0.textColor = .text
            }
            
            speakersLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinTop(to: titleLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
                $0.font = .karla(.italic, size: 14)
                $0.textColor = .text
            }
            
            dateLabel.add(toSuperview: contentView).customize {
                $0.pinLeading(to: contentView, plus: .padding).pinTrailing(to: contentView, plus: -.padding)
                $0.pinTop(to: speakersLabel, .bottom, plus: 10).constrainSize(toFit: .vertical)
                $0.font = .karla(.bold, size: 14)
                $0.textColor = .text
            }
            
        }
        
        func configure(guide: Contentful.Post) {
            titleLabel.text = guide.title
            speakersLabel.text = "Joe Daly, John Elmore, and Blake Holmes"
            dateLabel.text = DateFormatter.readable.string(from: guide.publishDate)
        }
        
        static func size(forEpisode episode: Contentful.Post, in view: UIView) -> CGSize {
            let width = view.width - .padding * 2
            let textWidth = width - .padding * 2
            
            let titleHeight = episode.title.size(boundingWidth: textWidth, font: .crimsonText(.semiBold, size: 22)).height
            let speakerHeight = "Joe Daly, John Elmore, and Blake Holmes".size(boundingWidth: textWidth, font: .karla(.italic, size: 14)).height
            let dateHeight = DateFormatter.readable.string(from: episode.publishDate).size(boundingWidth: textWidth, font: .karla(.bold, size: 14)).height
            
            let height = .padding + titleHeight.rounded(.up) + 10 + speakerHeight.rounded(.up) + 10 + dateHeight.rounded(.up) + .padding
            
            return CGSize(
                width: width,
                height: height
            )
        }
        
    }
    
}

extension LeadershipLessonsViewController {
    
    final class LatestEpisodeView: View {
        
        private var episode: Contentful.Post?
        
        private let backgroundImageView = LoadingImageView()
        private let gradientView        = GradientView()
        private let titleLabel          = UILabel()
        private let subtitleLabel       = UILabel()
        private let dateLabel           = UILabel()
        private let button              = UIButton()
        
        weak var delegate: LatestEpisodeViewDelegate?
        
        override func setup() {
            super.setup()
            
            constrainHeight(to: UIScreen.main.height * 0.62)
            
            backgroundImageView.add(toSuperview: self).customize {
                $0.constrainEdgesToSuperview()
                $0.contentMode = .scaleAspectFill
                $0.showDimmer = true
            }
            
            gradientView.add(toSuperview: self).customize {
                $0.pinLeading(to: self).pinTrailing(to: self)
                $0.pinBottom(to: self).constrainHeight(to: self, times: 0.42)
            }
            
            button.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinBottom(to: self, plus: -70)
                $0.constrainHeight(to: 30).constrainSize(toFit: .horizontal)
                $0.setAttributedTitle("  VIEW SHOW NOTES  ".attributed.font(.karla(.bold, size: 12)).kern(1).color(.text), for: .normal)
                $0.setBackgroundColor(.white, for: .normal)
                $0.cornerRadius = 4
                $0.addTarget(for: .touchUpInside) { [weak self] in
                    guard let self = self, let episode = self.episode else { return }
                    self.delegate?.didSelect(episode: episode, in: self)
                }
            }
            
            dateLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinBottom(to: button, .top, plus: -.padding)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.bold, size: 14)
                $0.textColor = .white
            }
            
            subtitleLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinBottom(to: dateLabel, .top)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.italic, size: 14)
                $0.textColor = .white
                $0.text = "Joe Daly, John Elmore, and Blake Holmes"
            }
            
            titleLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinBottom(to: subtitleLabel, .top, plus: -10).constrainSize(toFit: .vertical)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 35)
                $0.textColor = .white
            }
            
            addGesture(type: .tap) { [weak self] _ in
                guard let self = self, let episode = self.episode else { return }
                self.delegate?.didSelect(episode: episode, in: self)
            }
        }
        
        func configure(episode: Contentful.Post) {
            self.episode = episode
            
            dateLabel.text = DateFormatter.readable.string(from: episode.publishDate)
            titleLabel.text = episode.title
        }
        
    }
    
}

