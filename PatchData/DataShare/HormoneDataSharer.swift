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
    
    private let sites: HormoneSiteScheduling
    private let siteDataSharer: DataSharing
    private let defaults: UserDefaultsWriting
    
    init(sites: HormoneSiteScheduling, siteDataSharer: DataSharing, defaults: UserDefaultsWriting) {
        self.sites = sites
        self.siteDataSharer = siteDataSharer
        self.defaults = defaults
    }
    
    public func share(nextHormone: Hormonal) {
        let method = defaults.deliveryMethod
        let interval = defaults.expirationInterval
        let nextSite = sites.suggested
        let name = method.value == .Patches ? sites.suggested?.name : nextSite?.name
        siteDataSharer.shareRelevantHormoneData(
            oldestHormone: nextHormone,
            displayedSiteName: name ?? SiteStrings.newSite,
            interval: interval,
            deliveryMethod: method
        )
    }
}
