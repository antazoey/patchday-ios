//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PatchData
import PDKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let appDelegate = UIApplication.shared.delegate as! AppDelegate"
    
    internal var window: UIWindow?
    internal var notificationsController = PDNotificationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Load user defaults.
        PDDefaults.setUp()
        
        // Set default Pills only on the first launch.
        if isFirstLaunch() {
            PDSchedule.pillSchedule.reset()
        }

        // Load data for the Today widget.
        TodayData.setDataForTodayApp()
        
        // Set the correct app badge value.
        let interval = PDDefaults.getTimeInterval()
        setBadge(with: PDSchedule.totalDue(interval: interval))
        
        let count = PDDefaults.getQuantity()
        PDSchedule.estrogenSchedule.delete(after: count)

        // Set the nav bar appearance.
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.blue
        return true
    }
    
    func isFirstLaunch() -> Bool {
        return !PDDefaults.mentionedDisclaimer()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let interval = PDDefaults.getTimeInterval()
        setBadge(with: PDSchedule.totalDue(interval: interval))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let interval = PDDefaults.getTimeInterval()
        setBadge(with: PDSchedule.totalDue(interval: interval))
    }
    
    /** Sets the App badge number to the expired
    estrogen count + the total pills due for taking. */
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
    

}
