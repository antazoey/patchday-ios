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

        // Set default Pills only on the first launch.
        if isFirstLaunch() {
            PillSchedule.reset()
        }

        // Load data for the Today widget.
        Schedule.sharedData.setDataForTodayApp()
        
        // Set the correct app badge value.
        let interval = Defaults.getTimeInterval()
        setBadge(with: Schedule.totalDue(interval: interval))
        
        let count = Defaults.getQuantity()
        Schedule.estrogenSchedule.delete(after: count)

        // Set the nav bar appearance.
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.blue
        return true
    }
    
    func isFirstLaunch() -> Bool {
        return !Defaults.mentionedDisclaimer()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let interval = Defaults.getTimeInterval()
        setBadge(with: Schedule.totalDue(interval: interval))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let interval = Defaults.getTimeInterval()
        setBadge(with: Schedule.totalDue(interval: interval))
    }
    
    /** Sets the App badge number to the expired
    estrogen count + the total pills due for taking. */
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
}
