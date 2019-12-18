//
//  ApplyHormoneNotificationActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class ApplyHormoneNotificationActionHandler: ApplyHormoneNotificationActionHandling {
    
    private let sdk: PatchDataDelegate?
    private let badge: PDBadgeDelegate
    
    convenience init(sdk: PatchDataDelegate?) {
        self.init(sdk: sdk, appBadge: PDBadge())
    }
    
    init(sdk: PatchDataDelegate?, appBadge: PDBadgeDelegate) {
        self.sdk = sdk
        self.badge = appBadge
    }
    
    func applyHormone(hormoneUid: String) {
        if let id = UUID(uuidString: hormoneUid),
            let suggestedSite = sdk?.sites.suggested {
            sdk?.hormones.set(for: id, date: Date(), site: suggestedSite)
            badge.decrement()
        }
    }
}
