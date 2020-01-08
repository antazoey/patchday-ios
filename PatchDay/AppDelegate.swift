//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit
import PatchData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notifications: NotificationScheduling?
    var sdk: PatchDataDelegate = PatchData()
    var alerts: AlertDispatching?
    var tabs: TabReflective?
    var nav: NavigationDelegate = Navigation()
    var styles: Styling?
    var badge: PDBadgeDelegate = PDBadge()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.notifications = Notifications(sdk: sdk, appBadge: badge)
        self.alerts = AlertDispatcher(sdk: sdk)
        self.styles = Stylist(theme: self.sdk.defaults.theme.value)
        self.setBadgeToTotalAlerts()
        self.setNavigationAppearance()
        return true
    }
    
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var current: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    func applicationWillTerminate(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    func setNavigationAppearance() {
        if let styles = styles {
            nav.reflectTheme(theme: styles.theme)
            tabs?.reflectTheme(theme: styles.theme)
        }
    }

    func setTheme() {
        let t = sdk.defaults.theme.value
        self.styles = Stylist(theme: t)
        setNavigationAppearance()
    }

    /// Sets the App badge number to the expired count + the total pills due for taking.
    private func setBadgeToTotalAlerts() {
        badge.set(to: sdk.totalAlerts)
    }
}
