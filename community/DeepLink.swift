//
//  DeepLink.swift
//  community
//
//  Created by Jonathan Landon on 7/17/18.
//

import UIKit
import MessageUI
import Diakoneo

private final class Observer: NSObject {}

enum DeepLink {
    case message(Int)
    case series(Int)
    case post(String)
    case shelf(String)
    case entry(String)
    case url(URL)
    case unknown
    
    private static var observers: [Observer] = []
    
    init(path: String) {
        guard let scanner = Scanner(path: path) else {
            self = .unknown
            return
        }
        
        if scanner.components.first == "message", let id = scanner.components.at(1).flatMap(Int.init) {
            self = .message(id)
        }
        else if scanner.components.first == "series", let id = scanner.components.at(1).flatMap(Int.init) {
            self = .series(id)
        }
        else if scanner.components.first == "post", let id = scanner.components.at(1) {
            self = .post(id)
        }
        else if scanner.components.first == "shelf", let id = scanner.components.at(1) {
            self = .shelf(id)
        }
        else if scanner.components.first == "entry", let id = scanner.components.at(1) {
            self = .entry(id)
        }
        else if let url = URL(string: path) {
            self = .url(url)
        }
        else {
            self = .unknown
        }
    }
    
    func handle(fallback: URL? = nil) {
        switch self {
        case .message(let id):
            Watermark.API.Messages.fetch(id: id) { result in
                DispatchQueue.main.async {
                    guard let message = result.value else {
                        UIViewController.current?.showInSafari(url: fallback)
                        return
                    }
                    ContentViewController(message: message).show()
                }
            }
        case .series(let id):
            Watermark.API.Series.fetch(id: id) { result in
                DispatchQueue.main.async {
                    guard let series = result.value else {
                        UIViewController.current?.showInSafari(url: fallback)
                        return
                    }
                    SeriesViewController(series: series).show()
                }
            }
        case .post(let id):
            let observer = Observer()
            DeepLink.observers.append(observer)
            
            Notifier.onContentLoaded.subscribePastOnce(with: observer) {
                DeepLink.observers.remove(observer)
                Contentful.LocalStorage.posts.first(where: { $0.id == id })?.show(from: .deepLink)
            }.onQueue(.main)
        case .shelf(let id):
            let observer = Observer()
            DeepLink.observers.append(observer)
            
            Notifier.onContentLoaded.subscribePastOnce(with: observer) {
                DeepLink.observers.remove(observer)
                Contentful.LocalStorage.shelves.first(where: { $0.id == id })?.show(from: .deepLink)
            }.onQueue(.main)
        case .entry(let id):
            let observer = Observer()
            DeepLink.observers.append(observer)
            
            Notifier.onContentLoaded.subscribePastOnce(with: observer) {
                DeepLink.observers.remove(observer)
                
                if let post = Contentful.LocalStorage.externalPosts.first(where: { $0.id == id }) {
                    Contentful.Post.external(post).show(from: .deepLink)
                }
                else if let post = Contentful.LocalStorage.textPosts.first(where: { $0.id == id }) {
                    Contentful.Post.text(post).show(from: .deepLink)
                }
                else if let shelf = Contentful.LocalStorage.shelves.first(where: { $0.id == id }) {
                    shelf.show(from: .deepLink)
                }
            }.onQueue(.main)
        case .url(let url):
            let pathComponents = url.path.components(separatedBy: "/").filter { !$0.isEmpty }
            
            if url.host == "www.watermark.org" {
                if let id = pathComponents.at(1).flatMap(Int.init), pathComponents.at(0) == "message" {
                    DeepLink.message(id).handle(fallback: url)
                }
                else if let id = pathComponents.at(1).flatMap(Int.init), pathComponents.at(0) == "series" {
                    DeepLink.series(id).handle(fallback: url)
                }
                else {
                    UIViewController.current?.showInSafari(url: url)
                }
            }
            else if url.isHTTP {
                UIViewController.current?.showInSafari(url: url)
            }
            else if url.isEmail, MFMailComposeViewController.canSendMail(), UIViewController.current is MFMailComposeViewControllerDelegate {
                MFMailComposeViewController().customize {
                    $0.setToRecipients([url.absoluteString])
                    $0.mailComposeDelegate = UIViewController.current as? MFMailComposeViewControllerDelegate
                }.show()
            }
            else {
                UIApplication.shared.open(url)
            }
        case .unknown:
            break
        }
    }
    
    @discardableResult
    static func handle(url: URL) -> Bool {
        DeepLink(path: url.absoluteString).handle(fallback: url)
        return true
    }
}

extension DeepLink {
    
    struct Scanner {
        let components: [String]
        
        init?(path: String) {
            let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
            
            guard components.first == "watermark-community:" else { return nil }
            
            self.components = Array(components.dropFirst())
        }
    }
    
}
