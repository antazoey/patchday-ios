//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

// Mock these for testing
import UserNotifications
import PatchData

let app = (UIApplication.shared.delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let app = UIApplication.shared.delegate as! AppDelegate"
    
    var window: UIWindow?
    var notifications = PDNotificationSchedule()
    var sdk: PatchDataDelegate = PatchDataSDK()
    var alerts = PDAlertDispatcher()
    var tabs: PDTabReflector?
    var nav: PDNavigationDelegate = PDNavigationDelegate()
    var theme: PDThemeManager!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if isFirstLaunch() { sdk.pills.new() }
        //patchData.schedule.nuke()
        self.theme = PDThemeManager(theme: sdk.defaults.theme.value)
        sdk.broadcastEstrogens()
        setBadge()
        setNavigationAppearance()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setBadge()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setBadge()
    }
    
    func setTabs(tc: UITabBarController, vcs: [UIViewController]) {
        tabs = PDTabReflector(tabController: tc, viewControllers: vcs)
    }
    
    func isFirstLaunch() -> Bool {
        return !sdk.defaults.mentionedDisclaimer.value
    }
    
    func setNavigationAppearance() {
        nav.reflectTheme(theme: theme)
        tabs?.reflectTheme(theme: theme)
    }
    
    func resetTheme() {
        theme = PDThemeManager(theme: sdk.defaults.theme.value)
        setNavigationAppearance()
    }
    
    /** Sets the App badge number to the expired
    estrogen count + the total pills due for taking. */
    private func setBadge() {
        UIApplication.shared.applicationIconBadgeNumber = sdk.totalDue
    }
}
