//
//  DataShareDelegate.swift
//  PDKit
//
//  Created by Juliya Smith on 9/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol DataSharing {

    var defaults: UserDefaults? { get }
    
    /// Sets hormone data for other apps and widgets, such as the PatchDay Today widget.
    func shareRelevantHormoneData(
        oldestHormone: Hormonal,
        displayedSiteName: SiteName,
        interval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethodUD
    )
    
    /// Sets pill data for other apps and widgets, such as the PatchDay Today widget.
    func shareRelevantPillData(nextPill: Swallowable)
}
