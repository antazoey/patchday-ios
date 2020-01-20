//
//  HormoneDataBroadcasting.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class HormoneDataSharer: HormoneDataSharing {
    
    private let baseSharer: DataSharing
    private let sites: HormoneSiteScheduling
    private let defaults: UserDefaultsReading
    
    init(baseSharer: DataSharing, sites: HormoneSiteScheduling, defaults: UserDefaultsReading) {
        self.baseSharer = baseSharer
        self.sites = sites
        self.defaults = defaults
    }
    
    public func share(nextHormone: Hormonal) {
        let method = defaults.deliveryMethod
        let interval = defaults.expirationInterval
        let nextSite = sites.suggested
        let name = method.value == .Patches ? sites.suggested?.name : nextSite?.name
        shareRelevantHormoneData(
            oldestHormone: nextHormone,
            displayedSiteName: name ?? SiteStrings.newSite,
            interval: interval,
            deliveryMethod: method
        )
    }
    
    private func shareRelevantHormoneData(
        oldestHormone: Hormonal,
        displayedSiteName: SiteName,
        interval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethodUD
    ) {
        baseSharer.share(displayedSiteName, forKey: PDStrings.TodayKey.nextHormoneSiteName.rawValue)
        baseSharer.share(oldestHormone.date, forKey: PDStrings.TodayKey.nextHormoneDate.rawValue)
    }
}
