//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import PDKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let appDelegate = UIApplication.shared.delegate as! AppDelegate"
    
    internal var window: UIWindow?
    internal var notificationsController = PDNotificationController()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaultsController.setUp()
        if !UserDefaultsController.mentionedDisclaimer() {
            ScheduleController.pillController.pillArray = PillDataController.newPillMOs(into: ScheduleController.getContext())
        }
        ScheduleController.estrogenController.migrate(needs: UserDefaultsController.needsMigration())
        ScheduleController.setDataForTodayApp()
        
        setBadge(with: ScheduleController.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))

        // Navigation bar appearance
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.blue
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setBadge(with: ScheduleController.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setBadge(with: ScheduleController.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()))
    }
    
    /// Sets the App badge number to the expired estrogen count + the total pills due for taking.
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
    

}
