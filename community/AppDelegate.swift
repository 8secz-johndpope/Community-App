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
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarViewController()
        window?.makeKeyAndVisible()
        
        Contentful.API.initiailize(space: "943xvw9uyovc", token: "8884b9dc975dbcd97a1f5727f18c174c6453fccc98b2be07bbda40d28fc9b9f0")
        Content.loadAll()
        
        Analytics.appOpened()
        
        NotificationManager.setup(launchOptions: launchOptions, delegate: self)
        
        return true
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
