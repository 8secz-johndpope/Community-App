//
//  NotificationManager.swift
//  community
//
//  Created by Jonathan Landon on 3/16/19.
//

import UIKit
import UserNotifications
import FirebaseMessaging

enum NotificationManager {
    
    enum NotificationKey: String {
        case message = "messageID"
        case series = "seriesID"
        case post = "postID"
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
    
    static func setup(_ delegate: UNUserNotificationCenterDelegate & MessagingDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
        Messaging.messaging().delegate = delegate
        
        isPermissionsGranted { granted in
            DispatchQueue.main.async {
                if granted == true {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    static func register(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion(granted)
            }
        }
    }
    
    static func parse(userInfo: [String : Any]) -> DeepLink {
        if let id = userInfo[.message] as? String {
            return Int(id).flatMap(DeepLink.message) ?? .unknown
        }
        else if let id = userInfo[.series] as? String {
            return Int(id).flatMap(DeepLink.series) ?? .unknown
        }
        else if let id = userInfo[.post] as? String {
            return .post(id)
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

extension Dictionary where Key == String, Value: Any {
    
    subscript(_ key: NotificationManager.NotificationKey) -> Value? {
        return self[key.rawValue]
    }
    
}
