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


let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
let patchData = appDelegate.patchData
var tabs: PDTabViewDelegate?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let appDelegate = UIApplication.shared.delegate as! AppDelegate"
    
    var window: UIWindow?
    var notificationsController = PDNotificationController()
    var patchData = PatchDataSDK()
    var themeManager: ThemeManager!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set default Pills only on the first launch.
        if isFirstLaunch() {
            patchData.pillSchedule.reset()
        }
        let setSiteIndex = patchData.defaults.setSiteIndex
        
        // Uncomment to nuke the db
        //patchData.schedule.nuke()
        // Then re-comment, run again, and PatchDay resets to default.
        let theme = patchData.defaults.theme.value
        themeManager = ThemeManager(theme: theme)

        // Load data for the Today widget.
        patchData.schedule.sharedData.setDataForTodayApp(interval: patchData.defaults.expirationInterval,
                                               index: patchData.defaults.siteIndex.value,
                                               deliveryMethod: patchData.defaults.deliveryMethod,
                                               setSiteIndex: setSiteIndex)
        
        setBadge(with: patchData.schedule.totalDue(interval: patchData.defaults.expirationInterval))
        setNavigationAppearance()

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setBadge(with: patchData.schedule.totalDue(interval: patchData.defaults.expirationInterval))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setBadge(with: patchData.schedule.totalDue(interval: patchData.defaults.expirationInterval))
    }
    
    func isFirstLaunch() -> Bool {
        return !patchData.defaults.mentionedDisclaimer.value
    }
    
    internal func setNavigationAppearance() {
        //navigationController?.navigationBar.barTintColor = UIColor.black
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = themeManager.button_c
        navigationBarAppearace.barTintColor = themeManager.navbar_c
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : themeManager.text_c]
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = themeManager.button_c
        tabBarAppearance.barTintColor = themeManager.navbar_c
    }
    
    internal func resetTheme() {
        themeManager = ThemeManager(theme: patchData.defaults.theme.value)
        setNavigationAppearance()
    }
    
    /** Sets the App badge number to the expired
    estrogen count + the total pills due for taking. */
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
}
