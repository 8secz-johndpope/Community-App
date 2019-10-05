//
//  NotificationManager.swift
//  community
//
//  Created by Jonathan Landon on 3/16/19.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import OneSignal

enum NotificationManager {
    
    enum NotificationKey: String {
        case message = "messageID"
        case series = "seriesID"
        case post = "postID"
        case shelf = "shelfID"
        case url
        case unknown
    }
    
    static func isPermissionsGranted(completion: @escaping (Bool?) -> Void = { _ in }) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings { settings in
            
            let result: Bool?
            switch settings.authorizationStatus {
            case .notDetermined: result = nil
            case .denied:        result = false
            case .authorized:    result = true
            case .provisional:   result = true
            @unknown default:    result = nil
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static func setup(launchOptions: [UIApplication.LaunchOptionsKey : Any]?, delegate: UNUserNotificationCenterDelegate & MessagingDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
        Messaging.messaging().delegate = delegate
        
        OneSignal.initWithLaunchOptions(
            launchOptions ?? [:],
            appId: "2e1f4fe9-313c-4775-894c-f97a4116c96f",
            handleNotificationAction: { $0.flatMap(NotificationManager.handleNotification(result:)) },
            settings: [kOSSettingsKeyAutoPrompt: false]
        )
        
        OneSignal.inFocusDisplayType = .notification
        OneSignal.setLocationShared(false)
        
        isPermissionsGranted { granted in
            DispatchQueue.main.async {
                switch granted {
                case true: UIApplication.shared.registerForRemoteNotifications()
                case nil:  NotificationPromptViewController().present()
                default:   break
                }
            }
        }
    }
    
    static func handleNotification(result: OSNotificationOpenedResult) {
        guard
            let payload = result.notification.payload,
            let data = payload.additionalData
        else { return }
        
        parse(userInfo: data).handle()
    }
    
    static func register(completion: @escaping (Bool) -> Void = { _ in }) {
        OneSignal.promptForPushNotifications(userResponse: completion)
    }
    
    static func parse(userInfo: [AnyHashable : Any]) -> DeepLink {
        if let id = userInfo[.message] as? String {
            return Int(id).flatMap(DeepLink.message) ?? .unknown
        }
        else if let id = userInfo[.series] as? String {
            return Int(id).flatMap(DeepLink.series) ?? .unknown
        }
        else if let id = userInfo[.post] as? String {
            return .post(id)
        }
        else if let id = userInfo[.shelf] as? String {
            return .shelf(id)
        }
        else if let url = userInfo[.url] as? String {
            return URL(string: url).flatMap(DeepLink.url) ?? .unknown
        }
        else {
            return .unknown
        }
    }
    
    static func updateBadgeNumber() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count
            }
        }
    }
    
}

extension Dictionary where Key == AnyHashable, Value: Any {
    
    subscript(_ key: NotificationManager.NotificationKey) -> Value? {
        return self[key.rawValue]
    }
    
}
