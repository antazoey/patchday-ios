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
    
    private let sdk: PatchDataSDK?
    private let badge: PDBadgeDelegate
    
    convenience init(sdk: PatchDataSDK?) {
        self.init(sdk: sdk, appBadge: PDBadge())
    }
    
    init(sdk: PatchDataSDK?, appBadge: PDBadgeDelegate) {
        self.sdk = sdk
        self.badge = appBadge
    }
    
    func applyHormone(hormoneUid: String) {
        if let id = UUID(uuidString: hormoneUid),
            let suggestedSite = sdk?.sites.suggested {
            sdk?.hormones.set(by: id, date: Date(), site: suggestedSite, incrementSiteIndex: true, doSave: true)
            badge.decrement()
        }
    }
}
