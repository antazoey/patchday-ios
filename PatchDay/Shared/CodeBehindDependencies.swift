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
    
    let sdk: PatchDataDelegate?
    let tabs: TabReflective?
    let notifications: NotificationScheduling?
    let alerts: AlertDispatching?
    let styles: Styling?
    let nav: NavigationDelegate?
    
    init(
        sdk: PatchDataDelegate?,
        tabs: TabReflective?,
        notifications: NotificationScheduling?,
        alerts: AlertDispatching?,
        styles: Styling?,
        nav: NavigationDelegate?
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.notifications = notifications
        self.alerts = alerts
        self.styles = styles
        self.nav = nav
    }
    
    convenience init() {
        self.init(
            sdk: app?.sdk,
            tabs: app?.tabs,
            notifications: app?.notifications,
            alerts: app?.alerts,
            styles: app?.styles,
            nav: app?.nav
        )
    }
}
