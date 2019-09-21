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

let app = (UIApplication.shared.delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let app = UIApplication.shared.delegate as! AppDelegate"
    
    var window: UIWindow?
    var notifications = PDNotificationCenter()
    var sdk = PatchDataSDK()
    var alerts = PDAlertDispatcher()
    var tabs: PDTabViewDelegate?
    var nav: PDNavigationDelegate = PDNavigationDelegate()
    var theme: PDThemeManager!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set default Pills only on the first launch.
        if isFirstLaunch() { sdk.pills.reset() }
        
        // Uncomment to nuke the db
        //patchData.schedule.nuke()
        // Then re-comment, run again, and PatchDay resets to default.

        self.theme = PDThemeManager(theme: sdk.defaults.theme.value)

        // Load data for the Today widget.
        sdk.schedule.sharedData.setDataForTodayApp(interval: sdk.defaults.expirationInterval,
                                                   index: sdk.defaults.siteIndex.value,
                                                   deliveryMethod: sdk.defaults.deliveryMethod,
                                                   setSiteIndex: setSiteIndex)
        
        setBadge(with: patchData.sdk.schedule.totalDue(interval: patchData.sdk.defaults.expirationInterval))
        setNavigationAppearance()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        setBadge(with: patchData.sdk.schedule.totalDue(interval: sdk.defaults.expirationInterval))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        setBadge(with: sdk.schedule.totalDue(interval: sdk.defaults.expirationInterval))
    }
    
    func setTabs(tc: UITabBarController, vcs: [UIViewController]) {
        tabs = PDTabViewDelegate(tabController: tc, viewControllers: vcs)
    }
    
    func isFirstLaunch() -> Bool {
        return !sdk.defaults.mentionedDisclaimer.value
    }
    
    func setNavigationAppearance() {
        nav?.reflectTheme(theme: theme)
        tabs?.reflectTheme(theme: theme)
    }
    
    func resetTheme() {
        theme = PDThemeManager(theme: sdk.defaults.theme.value)
        setNavigationAppearance()
    }
    
    /** Sets the App badge number to the expired
    estrogen count + the total pills due for taking. */
    private func setBadge(with newBadgeNumber: Int) {
        UIApplication.shared.applicationIconBadgeNumber = newBadgeNumber
    }
}
