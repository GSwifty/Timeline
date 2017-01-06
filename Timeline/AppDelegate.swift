//
//  AppDelegate.swift
//  Timeline
//
//  Created by Garret Koontz on 1/2/17.
//  Copyright © 2017 GK. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        let nc = UNUserNotificationCenter.current()
        nc.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                print("Error requesting authorization for notifications: \(error)")
                return
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        UINavigationBar.appearance().barTintColor = UIColor(displayP3Red: 95/255, green: 95/255, blue: 90/255, alpha: 1.0)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        
        
        return true

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        PostController.sharedController.performFullSync()
        completionHandler(UIBackgroundFetchResult.newData)
    }



}

