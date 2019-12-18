//
//  CodeBehindDependencies.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CodeBehindDependencies {

    var tabs: TabReflective?
    let sdk: PatchDataDelegate?
    let notifications: NotificationScheduling?
    let alerts: AlertDispatching?
    let styles: Styling?
    let nav: NavigationDelegate?
    let badge: PDBadgeDelegate?
    
    init(
        sdk: PatchDataDelegate?,
        tabs: TabReflective?,
        notifications: NotificationScheduling?,
        alerts: AlertDispatching?,
        styles: Styling?,
        nav: NavigationDelegate?,
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
        let app = AppDelegate.current
        self.sdk = app?.sdk
        self.tabs = app?.tabs
        self.notifications = app?.notifications
        self.alerts = app?.alerts
        self.styles = app?.styles
        self.nav = app?.nav
        self.badge = app?.badge
    }
}
