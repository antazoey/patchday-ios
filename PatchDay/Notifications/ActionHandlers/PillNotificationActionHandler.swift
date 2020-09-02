//
//  SwallowPillNotificationActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillNotificationActionHandler: PillNotificationActionHandling {

    let pills: PillScheduling?
    let badge: PDBadgeDelegate

    init(_ pills: PillScheduling?, _ appBadge: PDBadgeDelegate) {
        self.pills = pills
        self.badge = appBadge
    }

    var requestPillNotification: ((_ pill: Swallowable) -> Void)?

    func handlePill(pillId: String) {
        guard let id = UUID(uuidString: pillId) else { return }
        guard let pills = pills else { return }
        guard let pill = pills[id] else { return }
        pills.swallow(id) {
            self.badge.reflect()
            self.requestPillNotification?(pill)
        }
    }
}
