//
//  AppDelegate.swift
//
//  Minimal UIKit application delegate retained via UIApplicationDelegateAdaptor
//  in PatchDayApp.swift. Hosts the DEBUG-only notification test hook; SwiftUI
//  handles all other lifecycle via @Environment(\.scenePhase).
//

import UIKit
import UserNotifications
import PDKit
import PatchData

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let container = AppContainer.shared
        #if DEBUG
        // `Notifications Test` is a debug scheme where the first hormone expires in a minute.
        if PDCli.isNotificationsTest() {
            container.badge?.clear()
            if let sdk = container.sdk, let notifications = container.notifications {
                if let hormone = sdk.hormones[0] {
                    notifications.requestExpiredHormoneNotification(for: hormone)
                }
                for pill in sdk.pills.all where pill.name == "Notification Test" {
                    notifications.requestDuePillNotification(pill)
                }
                }
            PDCli.clearNotificationsFlag()
        }
        #endif
        container.refreshBadges()
        return true
    }
}
