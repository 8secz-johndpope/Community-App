//
//  AppDelegate.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Diakoneo
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        MediaProgressManager.initialize()
        FirebaseApp.configure()
        
        let promptCount: Int = Storage.get(.notificationPromptDisplayCount) ?? 0
        Storage.set(promptCount + 1, for: .notificationPromptDisplayCount)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarViewController()
        window?.makeKeyAndVisible()
        
        Contentful.API.initiailize(space: "943xvw9uyovc", token: "m-j4wmVzPsoBQ2oyV1agQWdikRMmPfNKVx4FE7IuOzM")
        Content.loadAll()
        
        Analytics.appOpened()
        
        NotificationManager.setup(launchOptions: launchOptions, delegate: self)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return DeepLink.handle(url: url)
    }
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any] else { return completionHandler() }
        
        NotificationManager.parse(userInfo: userInfo).handle()
        NotificationManager.updateBadgeNumber()
        
        completionHandler()
    }
    
    //when app is opened
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.request.content.userInfo as? [String: Any] else { return completionHandler([]) }
        
        if case .message = NotificationManager.parse(userInfo: userInfo) {
            return completionHandler(.alert)
        }
        
        return completionHandler([])
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": fcmToken])
    }
}
