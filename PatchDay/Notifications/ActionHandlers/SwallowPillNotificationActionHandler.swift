//
//  SwallowPillNotificationActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SwallowPillNotificationActionHandler: SwallowPillNotificationActionHandling {

    let pills: PillScheduling?
    let badge: PDBadgeDelegate
    
    init(pills: PillScheduling?, appBadge: PDBadgeDelegate) {
        self.pills = pills
        self.badge = appBadge
    }

    var requestPillNotification: ((_ pill: Swallowable) -> ())?

    func swallow(pillUid: String) {
        if let pills = pills,
            let uuid = UUID(uuidString: pillUid),
            let pill = pills.get(by: uuid) {
            
            pills.swallow(pill) {
                self.requestPillNotification?(pill)
                self.badge.decrement()
            }
        }
    }
}
