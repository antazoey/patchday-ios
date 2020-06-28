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
	var sdk: PatchDataSDK?
	var alerts: AlertDispatching?
	var tabs: TabReflective?
	var nav: NavigationHandling?
	var badge: PDBadgeDelegate?

	private var sessionInitialized = false

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		initDependencies()
#if DEBUG
		// The `Notifications Test` is a test where the first hormone expires in a minute from now.
		if PDCli.isNotificationsTest() {
			badge?.clear()
			if let sdk = sdk, let notifications = notifications {
				if let hormone = sdk.hormones[0] {
					notifications.requestExpiredHormoneNotification(for: hormone)
				}
				if let pill = sdk.pills[0] {
					notifications.requestDuePillNotification(pill)
				}
			}
			PDCli.clearNotificationsFlag()
		}
		reflectBadges()
#endif
		return true
	}

	func initDependencies() {
		let sdk = PatchData()
		self.sdk = sdk
		self.nav = Navigation()
		let badge = PDBadge(sdk: sdk)
		self.badge = badge
		self.notifications = Notifications(sdk: sdk, appBadge: badge)
		self.alerts = AlertDispatcher(sdk: sdk, tabs: nil)
		reflectBadges()
	}

	static var isPad: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}

	static var current: AppDelegate? {
		UIApplication.shared.delegate as? AppDelegate
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		initDependencies()
		reflectBadges()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		reflectBadges()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		reflectBadges()
	}

	private func reflectBadges() {
		badge?.reflect()
		tabs?.reflect()
	}
}
