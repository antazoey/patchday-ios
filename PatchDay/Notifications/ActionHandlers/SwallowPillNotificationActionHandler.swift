//
//  PDSwallower.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SwallowPillNotificationActionHandler: SwallowPillNotificationActionHandling {
    
    let notifications: NotificationScheduling?
    let pills: PillScheduling?
    let badge: PDBadgeDelegate
    
    convenience init() {
        self.init(notifications: app?.notifications, pills: app?.sdk.pills, appBadge: PDBadge())
    }
    
    init(notifications: NotificationScheduling?, pills: PillScheduling?, appBadge: PDBadgeDelegate) {
        self.notifications = notifications
        self.pills = pills
        self.badge = appBadge
    }

    func swallow(pillUid: String) {
        if let pills = pills,
            let uuid = UUID(uuidString: pillUid),
            let pill = pills.get(for: uuid) {
            
            pills.swallow(pill) {
                self.notifications?.requestDuePillNotification(pill)
                self.badge.decrement()
            }
        }
    }
}
