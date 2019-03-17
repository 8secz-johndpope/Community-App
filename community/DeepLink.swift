//
//  DeepLink.swift
//  community
//
//  Created by Jonathan Landon on 7/17/18.
//

import UIKit
import MessageUI

private final class Observer: NSObject {}

enum DeepLink {
    case message(Int)
    case series(Int)
    case post(String)
    case url(URL)
    case unknown
    
    private static var observers: [Observer] = []
    
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
        case .url(let url):
            if url.isHTTP {
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
    
    static func handle(url: URL) {
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
        else {
            DeepLink.url(url).handle()
        }
    }
}
