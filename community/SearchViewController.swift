//
//  SearchViewController.swift
//  community
//
//  Created by Jonathan Landon on 8/7/18.
//

import UIKit
import Alexandria

final class SearchViewController: ViewController {
    
    enum Cell {
        case header(String)
        case suggestion(String)
        case shelves([Contentful.Shelf])
        case posts([Contentful.Post])
        case series([Watermark.Series])
        case messages([Watermark.Message])
        case speakers([Watermark.Speaker])
        
        static var suggestions: [Cell] {
            let searchSuggestions = Contentful.LocalStorage.search?.suggestions.map(Cell.suggestion) ?? []
            
            if searchSuggestions.isEmpty {
                return []
            }
            else {
                return [.header("Try Searching")] + searchSuggestions
            }
        }
        
        func size(in collectionView: UICollectionView) -> CGSize {
            switch self {
            case .header(let text):           return SearchHeaderCell.size(forText: text, in: collectionView)
            case .suggestion(let suggestion): return SearchSuggestionCell.size(forSuggestion: suggestion, in: collectionView)
            case .shelves:                    return SearchShelvesCell.size(in: collectionView)
            case .posts(let posts):           return SearchPostsCell.size(forPosts: posts, in: collectionView)
            case .series:                     return SearchSeriesCell.size(in: collectionView)
            case .messages(let messages):     return SearchMessagesCell.size(forMessages: messages, in: collectionView)
            case .speakers:                   return SearchSpeakersCell.size(in: collectionView)
            }
        }
    }
    
    private var cells: [Cell] = Cell.suggestions
    
    private var headerHeight: CGFloat = 154
    
    private let headerShadowView = ShadowView()
    private let headerView       = UIView()
    private let headerLabel      = UILabel()
    private let searchField      = UITextField()
    private let collectionView   = UICollectionView(layout: .vertical(lineSpacing: .padding))
    private let loadingIndicator = LoadingView()
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .lightBackground
        
        collectionView.add(toSuperview: view).customize {
            $0.constrainEdgesToSuperview()
            $0.registerCell(SearchHeaderCell.self)
            $0.registerCell(SearchSuggestionCell.self)
            $0.registerCell(SearchShelvesCell.self)
            $0.registerCell(SearchPostsCell.self)
            $0.registerCell(SearchSeriesCell.self)
            $0.registerCell(SearchMessagesCell.self)
            $0.registerCell(SearchSpeakersCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.contentInset.top = headerHeight + 20
            $0.contentInset.bottom = .padding
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.backgroundColor = .lightBackground
        }
        
        headerView.add(toSuperview: view).customize {
            $0.pinLeading(to: view).pinTrailing(to: view)
            $0.pinTop(to: view).pinSafely(.bottom, to: view, .top, plus: headerHeight)
            $0.backgroundColor = .lightBackground
        }
        
        headerShadowView.add(toSuperview: view, behind: headerView).customize {
            $0.pinLeading(to: headerView).pinTrailing(to: headerView)
            $0.pinTop(to: headerView).pinBottom(to: headerView)
            $0.shadowOpacity = 0.1
            $0.alpha = 0
        }
        
        searchField.add(toSuperview: headerView).customize {
            $0.pinLeading(to: headerView, plus: .padding).pinTrailing(to: headerView, plus: -.padding)
            $0.pinBottom(to: headerView, plus: -10).constrainHeight(to: 44)
            $0.borderStyle = .roundedRect
            $0.attributedPlaceholder = "Tell us what you're looking for".attributed.font(.regular(size: 14)).color(.gray)
            $0.leftView = UILabel().customize {
                $0.font = .fontAwesome(.light, size: 16)
                $0.textColor = .gray
                $0.textAlignment = .right
                $0.set(icon: .search)
                $0.sizeToFit()
                $0.width += 10
            }
            $0.leftViewMode = .always
            $0.font = .regular(size: 16)
            $0.textColor = .dark
            $0.returnKeyType = .search
            $0.delegate = self
            $0.clearButtonMode = .always
        }
        
        headerLabel.add(toSuperview: headerView).customize {
            $0.pinLeading(to: headerView, plus: .padding).pinTrailing(to: headerView, plus: -.padding)
            $0.pinBottom(to: searchField, .top, plus: -10).constrainSize(toFit: .vertical)
            $0.font = .header
            $0.textColor = .dark
            $0.text = "Search"
        }
        
        loadingIndicator.add(toSuperview: view).customize {
            $0.pinCenterX(to: view).pinCenterY(to: view)
            $0.constrainWidth(to: 30).constrainHeight(to: 30)
            $0.color = .dark
        }
        
        reload()
        
        Notifier.onSearchChanged.subscribePast(with: self) { [weak self] in
            self?.reload()
        }.onQueue(.main)
    }
    
    private func reload() {
        cells = Cell.suggestions
        collectionView.reloadData()
    }
    
    private func search(query: String) {
        
        view.endEditing(true)
        
        loadingIndicator.startAnimating()
        
        cells = []
        collectionView.reloadData()
        
        let processor = SimpleSerialProcessor()
        
        var shelves: [Contentful.Shelf]   = []
        var posts: [Contentful.Post]      = []
        
        // Shelves
        processor.enqueue { dequeue in
            Contentful.API.Shelf.search(query: query) { result in
                print("Shelves: \(result.value?.count ?? -1)")
                shelves.append(contentsOf: result.value ?? [])
                dequeue()
            }
        }
        
        // Text Posts
        processor.enqueue { dequeue in
            Contentful.API.TextPost.search(query: query) { result in
                print("Text Posts: \(result.value?.count ?? -1)")
                posts.append(contentsOf: result.value?.map(Contentful.Post.text) ?? [])
                dequeue()
            }
        }
        
        // External Posts
        processor.enqueue { dequeue in
            Contentful.API.ExternalPost.search(query: query) { result in
                print("External Posts: \(result.value?.count ?? -1)")
                posts.append(contentsOf: result.value?.map(Contentful.Post.external) ?? [])
                posts.sort(by: { $0.publishDate > $1.publishDate })
                dequeue()
            }
        }
        
        // Done
        processor.enqueue { dequeue in
            print("Finished!")
            
            DispatchQueue.main.async {
                var cells: [Cell] = []
                
                if !shelves.isEmpty {
                    cells.append(contentsOf: [
                        .header("Shelves"),
                        .shelves(shelves)
                    ])
                }
                if !posts.isEmpty {
                    cells.append(contentsOf: [
                        .header("Posts"),
                        .posts(posts)
                    ])
                }
                
                Analytics.searched(query: query, shelfCount: shelves.count, postCount: posts.count)
                
                self.cells = cells
                self.collectionView.reloadData()
                self.loadingIndicator.stopAnimating()
            }
            
            dequeue()
        }
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        reload()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        if let text = textField.text, !text.isEmpty {
            search(query: text)
        }
        
        return true
    }
    
}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case .header(let text):
            let cell: SearchHeaderCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(text: text)
            return cell
        case .suggestion(let suggestion):
            let cell: SearchSuggestionCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(suggestion: suggestion)
            return cell
        case .shelves(let shelves):
            let cell: SearchShelvesCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(shelves: shelves)
            return cell
        case .posts(let posts):
            let cell: SearchPostsCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(posts: posts)
            return cell
        case .series(let series):
            let cell: SearchSeriesCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(series: series)
            return cell
        case .messages(let messages):
            let cell: SearchMessagesCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(messages: messages)
            return cell
        case .speakers(let speakers):
            let cell: SearchSpeakersCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(speakers: speakers)
            return cell
        }
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.adjustedOffset.y
        
        if offset >= 0 {
            headerView.transform = .translate(0, -offset.limited(0, headerHeight - 64))
            headerShadowView.transform = .translate(0, -offset.limited(0, headerHeight - 64))
        }
        else {
            headerView.transform = .translate(0, pow(-offset, 0.7))
            headerShadowView.transform = .translate(0, pow(-offset, 0.7))
        }
        
        headerLabel.alpha = 1 - scrollView.adjustedOffset.y.map(from: 0...100, to: 0...1).limited(0, 1)
        headerShadowView.alpha = scrollView.adjustedOffset.y.map(from: 75...(headerHeight - 64), to: 0...1).limited(0, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cells[indexPath.row].size(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = cells.at(indexPath.row) else { return }
        
        if case .suggestion(let suggestion) = cell {
            searchField.text = suggestion
            search(query: suggestion)
        }
    }
    
}
