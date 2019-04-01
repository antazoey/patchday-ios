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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set default Pills only on the first launch.
        if isFirstLaunch() {
            PillScheduleRef.reset()
        }
        let interval = Defaults.getTimeInterval()
        let index = Defaults.getSiteIndex()
        let usingPatches = Defaults.usingPatches()
        let setSiteIndex = Defaults.setSiteIndex
        
        // Uncomment to nuke the db
        // Schedule.nuke()
        // Then re-comment, run again, and PatchDay resets to default.

        // Load data for the Today widget.
        Schedule.sharedData.setDataForTodayApp(interval: interval,
                                               index: index,
                                               usingPatches: usingPatches,
                                               setSiteIndex: setSiteIndex)
        
        // Set the correct app badge value.
        setBadge(with: Schedule.totalDue(interval: interval))

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
