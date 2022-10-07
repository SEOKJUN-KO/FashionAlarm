//
//  AppDelegate.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/12.
//

import UIKit
import NotificationCenter // 노티피케이션 사용하기 위함
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let userNotificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 노티피케이션 표시가 될 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound]) // 표시해주는 것
        print("hi1")
//        userNotificationCenter.addInfiniteNotificationRequest()
    }
    // 노티피케이션 받고 난 후
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        print("hi2")
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["FashionAlarmInfiniteAlarmOne", "FashionAlarmInfiniteAlarmTwo"])
    }
}

