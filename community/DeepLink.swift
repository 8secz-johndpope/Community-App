//
//  DeepLink.swift
//  community
//
//  Created by Jonathan Landon on 7/17/18.
//

import UIKit
import MessageUI

enum DeepLink {
    case message(Int)
    case url(URL)
    
    static func handle(url: URL) {
        let pathComponents = url.path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        if url.host == "www.watermark.org" {
            if let id = pathComponents.at(1).flatMap(Int.init), pathComponents.at(0) == "message" {
                Watermark.API.Messages.fetch(id: id) { result in
                    DispatchQueue.main.async {
                        guard let message = result.value else {
                            UIViewController.current?.showInSafari(url: url)
                            return
                        }
                        ContentViewController(message: message).show()
                    }
                }
            }
            else if let id = pathComponents.at(1).flatMap(Int.init), pathComponents.at(0) == "series" {
                Watermark.API.Series.fetch(id: id) { result in
                    DispatchQueue.main.async {
                        guard let series = result.value else {
                            UIViewController.current?.showInSafari(url: url)
                            return
                        }
                        SeriesViewController(series: series).show()
                    }
                }
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
    }
}
