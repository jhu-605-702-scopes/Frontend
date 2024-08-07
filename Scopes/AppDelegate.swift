//
//  AppDelegate.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import Foundation
import UIKit
import AWSCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // MARK: AWS Configuration
        let awsCredentialsProvider = AWSStaticCredentialsProvider(accessKey: AWSConfig.awsAccessKey, secretKey: AWSConfig.awsSecretKey)
        let awsConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: awsCredentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = awsConfiguration
        
        // MARK: Notification register
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        return true
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
         let token = tokenParts.joined()
         print("Device Token: \(token)")
        // paste this into sns
     }

     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("Failed to register: \(error)")
     }
}

extension AppDelegate {

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received remote notification: \(userInfo)")
        print("got notif")
        completionHandler(.newData)
    }
}

