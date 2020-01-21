//
//  SermonGuidesViewController.swift
//  community
//
//  Created by Jonathan Landon on 1/20/20.
//

import UIKit
import Diakoneo

protocol LatestGuideViewDelegate: class {
    func didSelect(guide: Contentful.Post, in view: SermonGuidesViewController.LatestGuideView)
    func didDetermine(color: UIColor, in view: SermonGuidesViewController.LatestGuideView)
}

final class SermonGuidesViewController: ViewController {
    
    private let collectionView = UICollectionView(layout: .vertical(itemSpacing: .padding, lineSpacing: .padding, sectionInset: UIEdgeInsets(top: UIScreen.main.height * 0.62 - 80, bottom: .padding)))
    private let latestGuideView = LatestGuideView()
    
    private var guides: [Contentful.Post] = []
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .black
        
        latestGuideView.add(toSuperview: view).customize {
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
        
        Notifier.onTableChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func reload() {
        guard let table = Contentful.LocalStorage.table else { return }
        
        let latest = table.posts[0]
        latestGuideView.configure(guide: latest)
        guides = Array(table.posts.dropFirst())
        
        collectionView.reloadData()
    }
    
}

extension SermonGuidesViewController: LatestGuideViewDelegate {
    
    func didSelect(guide: Contentful.Post, in view: SermonGuidesViewController.LatestGuideView) {
        guide.show(from: .table)
    }
    
    func didDetermine(color: UIColor, in view: SermonGuidesViewController.LatestGuideView) {
        self.view.backgroundColor = color
    }
    
}

extension SermonGuidesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueCell(for: indexPath)
        cell.configure(guide: guides[indexPath.row])
        return cell
    }
    
}

extension SermonGuidesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        latestGuideView.transform = .translate(0, -(scrollView.adjustedOffset.y * 0.2).limited(0, .greatestFiniteMagnitude))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.width - .padding * 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let guide = guides.at(indexPath.row) else { return }
        guide.show(from: .table)
    }
    
}

extension SermonGuidesViewController {
    
    final class Cell: CollectionViewCell {
        
        private let containerView = ContainerShadowView()
        private let imageView     = LoadingImageView()
        private let titleLabel    = UILabel()
        private let dateLabel     = UILabel()
        private let blurView      = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        private let readLabel     = UILabel()
        
        override func setup() {
            super.setup()
            
            containerView.add(toSuperview: contentView).customize {
                $0.constrainEdgesToSuperview()
                $0.containerCornerRadius = 8
            }
            
            imageView.add(toSuperview: containerView.container).customize {
                $0.constrainEdgesToSuperview()
                $0.contentMode = .scaleAspectFill
                $0.showDimmer = true
            }

            blurView.add(toSuperview: containerView.container).customize {
                $0.pinLeading(to: containerView.container).pinTrailing(to: containerView.container)
                $0.pinBottom(to: containerView.container).constrainHeight(to: 60)
            }

            readLabel.add(toSuperview: containerView.container).customize {
                $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
                $0.pinCenterY(to: blurView).constrainSize(toFit: .vertical)
                $0.font = .karla(.regular, size: 14)
                $0.textColor = .white
                $0.text = "View Sermon Guide"
            }
            
            dateLabel.add(toSuperview: containerView.container).customize {
                $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
                $0.pinBottom(to: blurView, .top, plus: -.padding).constrainSize(toFit: .vertical)
                $0.font = .karla(.regular, size: 14)
                $0.textColor = .white
            }
            
            titleLabel.add(toSuperview: containerView.container).customize {
                $0.pinLeading(to: containerView.container, plus: .padding).pinTrailing(to: containerView.container, plus: -.padding)
                $0.pinBottom(to: dateLabel, .top, plus: -5).constrainSize(toFit: .vertical)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 25)
                $0.textColor = .white
            }
            
        }
        
        func configure(guide: Contentful.Post) {
            imageView.load(url: guide.image)
            titleLabel.text = guide.title
            dateLabel.text = DateFormatter.readable.string(from: guide.publishDate)
        }
        
    }
    
}

extension SermonGuidesViewController {
    
    final class LatestGuideView: View {
        
        private var guide: Contentful.Post?
        
        private let backgroundImageView = LoadingImageView()
        private let gradientView        = GradientView()
        private let titleLabel          = UILabel()
        private let subtitleLabel       = UILabel()
        private let dateLabel           = UILabel()
        private let button              = UIButton()
        
        weak var delegate: LatestGuideViewDelegate?
        
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
                $0.setAttributedTitle("  VIEW SERMON GUIDE  ".attributed.font(.karla(.bold, size: 12)).kern(1).color(.text), for: .normal)
                $0.setBackgroundColor(.white, for: .normal)
                $0.cornerRadius = 4
                $0.addTarget(for: .touchUpInside) { [weak self] in
                    guard let self = self, let guide = self.guide else { return }
                    self.delegate?.didSelect(guide: guide, in: self)
                }
            }
            
            dateLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinBottom(to: button, .top, plus: -.padding)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.regular, size: 14)
                $0.textColor = .white
            }
            
            subtitleLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinBottom(to: dateLabel, .top)
                $0.constrainSize(toFit: .vertical, .horizontal)
                $0.font = .karla(.regular, size: 14)
                $0.textColor = .white
                $0.text = "Better Together 2020"
            }
            
            titleLabel.add(toSuperview: self).customize {
                $0.pinLeading(to: self, plus: .padding).pinTrailing(to: self, plus: -.padding)
                $0.pinBottom(to: subtitleLabel, .top).constrainSize(toFit: .vertical)
                $0.numberOfLines = 0
                $0.font = .crimsonText(.semiBold, size: 35)
                $0.textColor = .white
            }
            
            addGesture(type: .tap) { [weak self] _ in
                guard let self = self, let guide = self.guide else { return }
                self.delegate?.didSelect(guide: guide, in: self)
            }
        }
        
        func configure(guide: Contentful.Post) {
            self.guide = guide
            
            backgroundImageView.load(url: guide.image)
            dateLabel.text = DateFormatter.readable.string(from: guide.publishDate)
            titleLabel.text = guide.title
            
            backgroundImageView.load(url: guide.image) { [weak self] _ in
                guard let image = self?.backgroundImageView.image else { return }
                
                let colors = image.getColors()
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.delegate?.didDetermine(color: colors.primary, in: self)
                    self.gradientView.configure(
                        gradient: Gradient(colors: colors.primary, colors.primary.alpha(0)),
                        direction: .vertical
                    )
                }
            }
        }
        
    }
    
}
