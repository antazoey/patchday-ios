//
//  PDDateSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 9/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol DataShareDelegate {
    var defaults: UserDefaults? { get }
    
    /// Sets hormone data for other apps and widgets, such as the PatchDay Today widget.
    func broadcastRelevantHormoneData(
        oldestHormone: Hormonal,
        nextSuggestedSite: SiteName,
        interval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethodUD
    )
    
    /// Sets pill data for other apps and widgets, such as the PatchDay Today widget.
    func broadcastRelevantPillData(nextPill: PillStruct)
}
