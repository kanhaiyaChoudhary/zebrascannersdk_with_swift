//
//  AppDelegate.swift
//  ScannerSample
//
//  Created by Kanhaiya Chaudhary on 17/12/18.
//  Copyright © 2018 Kanhaiya Chaudhary. All rights reserved.
//

import UIKit

var baecode_Arr:[String] = []

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        zt_ScannerAppEngine.shared()
        ConnectionManager.shared().initializeConnectionManager()
        
        /* the application is really started by notification, not just switched
         from backround to foreground */
        let bg_notification = launchOptions?[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification
        if bg_notification != nil {
            zt_ScannerAppEngine.shared().processBackroundNotification(bg_notification)
        }
        
        if Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0 {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        // Extend the splash screen for 1.75 seconds.
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.75))
        
        //var docDir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").absoluteString
        //var workDir = URL(fileURLWithPath: docDir).appendingPathComponent(ZT_FW_FILE_DIRECTIORY_NAME).absoluteString
        //createDir(workDir)

        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

