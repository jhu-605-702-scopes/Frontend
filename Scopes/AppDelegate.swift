//
//  AppDelegate.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import Foundation
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("deviceToken") private var storedToken: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications(application)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        if token != storedToken {
            storedToken = token
            print("New Device Token saved: \(token)")
            // Send the token off to AWS
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received remote notification: \(userInfo)")
        completionHandler(.newData)
    }
}

extension AppDelegate {
    private func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.getNotificationSettings(application)
        }
    }

    // if the user changes their mind
    private func getNotificationSettings(_ application: UIApplication) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}
