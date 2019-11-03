//
//  PDDateSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 9/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDDataMeting  {
    var defaults: UserDefaults? { get }
    func broadcastRelevantHormoneData(
        oldestHormone: Hormonal,
        nextSuggestedSite: SiteName,
        interval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethodUD
    )
    func broadcastRelevantPillData(nextPill: Swallowable)
}
