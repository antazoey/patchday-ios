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
    internal var datePicker = UIDatePicker()
    internal var sharedDefaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaultsController.setUp()
        PillDataController.setUp()
        
        // Set TB status for PatchDay Today
        if PillDataController.includingTB() {
            let tbTakenToday = PDPillsHelper.takenTodayCount(stamps: PillDataController.tb_stamps)
            if let defaults = sharedDefaults {
                defaults.set(tbTakenToday, forKey: PDStrings.TodayKeys.tbTaken)
            }
        }
        
        // unhide for resetting (for testing):
        //ScheduleController.resetPatchData()
        
        // Navigation bar appearance
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.darkGray

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Badge correction
        UIApplication.shared.applicationIconBadgeNumber = ScheduleController.estrogenSchedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Badge correction
        UIApplication.shared.applicationIconBadgeNumber = ScheduleController.estrogenSchedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue()
    }

}
