//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // get reference by let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var window: UIWindow?
    
    var notificationsController = PDNotificationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SettingsController.startUp()
        PatchDataController.syncWithCloud()
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
        // Saves changes in the application's managed object context before the application terminates.
       // self.patchDataController.saveContext()
    }
    
    public func iCloudToken() -> NSObjectProtocol? {
        if let token = FileManager.default.ubiquityIdentityToken {
            return token
        }
        return nil
    }
    
    public func iCloudIsAvailable() -> Bool {
        // when iCloud is available, this property contains an opaque
        if let token = iCloudToken() {
            if let recordedToken = SettingsDefaultsController.getCloudKey() {
                if token.isEqual(recordedToken) {
                    return true
                }
                else {
                    // return false if tokens are mismatch
                    return false
                }
            }
            else {
                SettingsDefaultsController.setCloudKey(to: token)
            }
            return true
        }
        // nil otherwise
        else {
            return false
        }
    }
}
