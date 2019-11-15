//
//  SettingsCodeBehind.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsCodeBehind {
    
    let sdk: PatchDataDelegate?
    let tabs: TabReflective?
    let notifications: NotificationScheduling?
    let alerts: AlertDispatching?
    
    convenience init() {
        self.init(
            sdk: app?.sdk,
            tabs: app?.tabs,
            notifications: app?.notifications,
            alerts: app?.alerts
        )
    }
    
    init(
        sdk: PatchDataDelegate?,
        tabs: TabReflective?,
        notifications: NotificationScheduling?,
        alerts: AlertDispatching?
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.notifications = notifications
        self.alerts = alerts
    }
}
