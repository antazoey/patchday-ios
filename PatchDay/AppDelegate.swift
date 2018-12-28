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
    
    public func isFirstLaunch() -> Bool {
        return UserDefaultsController.needsMigration()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Load user defaults.
        UserDefaultsController.setUp()

        // Set default Pills only on the first launch.
        if isFirstLaunch() {
            PDSchedule.pillSchedule.reset()
        }

        // Load data for the Today widget.
        TodayData.setDataForTodayApp()
        
        // Set the correct app badge value.
        setBadge(with: PDSchedule.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))
        
        PDSchedule.estrogenSchedule.deleteExtra(after: UserDefaultsController.getQuantityInt())

        // Set the nav bar appearance.
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.blue
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setBadge(with: PDSchedule.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setBadge(with: PDSchedule.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))
    }
    
    /// Sets the App badge number to the expired estrogen count + the total pills due for taking.
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
    

}
