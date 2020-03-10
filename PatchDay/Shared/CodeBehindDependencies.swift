//
//  CodeBehindDependencies.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CodeBehindDependencies<T> {

    let sdk: PatchDataSDK?
    var tabs: TabReflective?
    let notifications: NotificationScheduling?
    let alerts: AlertDispatching?
    let styles: Styling?
    let nav: NavigationHandling?
    let badge: PDBadgeDelegate?
    
    lazy var log = PDLog<CodeBehindDependencies>()
    lazy var contextClass = String(describing: T.self)
    
    init(
        sdk: PatchDataSDK?,
        tabs: TabReflective?,
        notifications: NotificationScheduling?,
        alerts: AlertDispatching?,
        styles: Styling?,
        nav: NavigationHandling?,
        badge: PDBadgeDelegate?
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.notifications = notifications
        self.alerts = alerts
        self.styles = styles
        self.nav = nav
        self.badge = badge
    }

    init() {
        if let app = AppDelegate.current {
            self.sdk = app.sdk
            self.tabs = app.tabs
            self.notifications = app.notifications
            self.alerts = app.alerts
            self.styles = app.styles
            self.nav = app.nav
            self.badge = app.badge
        } else {
            self.sdk = nil
            self.tabs = nil
            self.notifications = nil
            self.alerts = nil
            self.styles = nil
            self.nav = nil
            self.badge = nil
            log.error("App is not yet initialized before \(contextClass)")
        }
    }
}
