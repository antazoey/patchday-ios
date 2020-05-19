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
		
		// The `Notifications Test` is a test where the first hormone expires in a minute from now.
		if PDCli.isNotificationsTest() {
			self.notifications?.requestExpiredHormoneNotification(for: sdk!.hormones[0]!)
		}
		return true
	}
	
	func initDependencies() {
		guard !sessionInitialized else { return }
		let sdk = PatchData()
		self.sdk = PatchData()
		self.nav = Navigation()
		let badge = PDBadge(sdk: sdk)
		self.badge = badge
		self.notifications = Notifications(sdk: sdk, appBadge: badge)
		self.alerts = AlertDispatcher(sdk: sdk)
		self.badge?.reflect()
		sessionInitialized = true
	}

	static var isPad: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}

	static var current: AppDelegate? {
		UIApplication.shared.delegate as? AppDelegate
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		sessionInitialized = false
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		sessionInitialized = false
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		initDependencies()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		badge?.reflect()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		badge?.reflect()
	}
}
