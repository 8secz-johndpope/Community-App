//
//  AppDelegate.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarViewController()
        window?.makeKeyAndVisible()
        
        var entries: [Contentful.Entry] = []
        var assets: [Contentful.Asset] = []
        
        let processor = SimpleSerialProcessor()
        
        processor.enqueue { dequeue in
            Contentful.API.Content.fetchAll { result in
                print("All content: \(result.value?.count ?? -1)")
                entries = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { dequeue in
            Contentful.API.Asset.fetchAll { result in
                print("All assets: \(result.value?.count ?? -1)")
                assets = result.value ?? []
                dequeue()
            }
        }
        
        processor.enqueue { dequeue in

            var authors: [Contentful.Author] = []
            var externalPosts: [Contentful.ExternalPost] = []
            var textPosts: [Contentful.TextPost] = []
            var shelves: [Contentful.Shelf] = []
            var pantry: Contentful.Pantry?

            for entry in entries {
                switch entry {
                case .author(let author):             authors.append(author)
                case .externalPost(let externalPost): externalPosts.append(externalPost)
                case .pantry(let p):                  pantry = p
                case .textPost(let textPost):         textPosts.append(textPost)
                case .shelf(let shelf):               shelves.append(shelf)
                }
            }
            
            Contentful.LocalStorage.authors       = authors
            Contentful.LocalStorage.assets        = assets
            Contentful.LocalStorage.externalPosts = externalPosts
            Contentful.LocalStorage.textPosts     = textPosts
            Contentful.LocalStorage.shelves       = shelves
            Contentful.LocalStorage.pantry        = pantry
            
            Notifier.onTableChanged.fire(())
            
            dequeue()
        }
        
        Watermark.API.Series.fetch { result in
            print("Series: \(result.value?.count ?? -1)")
        }
        
        return true
    }

}

