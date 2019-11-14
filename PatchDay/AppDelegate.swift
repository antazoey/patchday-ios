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

let isResetMode = false  // Change this to true to nuke the database
let app: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notifications: PDNotificationScheduling = PDNotifications()
    var sdk: PatchDataDelegate = PatchData()
    var alerts: PDAlertDispatching = PDAlertDispatcher()
    var tabs: PDTabReflective?
    var nav: PDNavigationDelegate = PDNavigation()
    var styles: PDStyling!
    var badge: PDBadgeDelegate = PDBadge()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if isResetMode {
            sdk.nuke()
            return false
        }

        self.styles = PDStylist(theme: self.sdk.defaults.theme.value)
        self.setBadgeToTotalAlerts()
        self.setNavigationAppearance()
        return true
    }
    
    static var isPad: Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }

    func applicationWillTerminate(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    func setTabs(tc: UITabBarController, vcs: [UIViewController]) {
        tabs = PDTabReflector(tabController: tc, viewControllers: vcs)
    }

    func isFirstLaunch() -> Bool {
        return !sdk.defaults.mentionedDisclaimer.value
    }

    func setNavigationAppearance() {
        nav.reflectTheme(theme: styles.theme)
        tabs?.reflectTheme(theme: styles.theme)
    }

    func resetTheme() {
        let t = sdk.defaults.theme.value
        self.styles = PDStylist(theme: t)
        setNavigationAppearance()
    }

    /// Sets the App badge number to the expired count + the total pills due for taking.
    private func setBadgeToTotalAlerts() {
        badge.set(to: sdk.totalAlerts)
    }
}
