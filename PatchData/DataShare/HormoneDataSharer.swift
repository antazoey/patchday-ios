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
    private let sites: SiteScheduling
    private let settings: UserDefaultsReading
    
    init(baseSharer: DataSharing, sites: SiteScheduling, settings: UserDefaultsReading) {
        self.baseSharer = baseSharer
        self.sites = sites
        self.settings = settings
    }
    
    public func share(nextHormone: Hormonal) {
        let method = settings.deliveryMethod
        let interval = settings.expirationInterval
        let nextSite = sites.suggested
        let name = method.value == .Patches ? sites.suggested?.name : nextSite?.name
        shareRelevantHormoneData(
            oldestHormone: nextHormone,
            displayedSiteName: name ?? SiteStrings.NewSite,
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
        baseSharer.share(displayedSiteName, forKey: TodayKey.nextHormoneSiteName.rawValue)
        baseSharer.share(oldestHormone.date, forKey: TodayKey.nextHormoneDate.rawValue)
    }
}
