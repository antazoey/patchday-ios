//
//  HormoneDataBroadcasting.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class HormoneDataBroadcaster : HormoneDataBroadcasting {
    
    private let sites: HormoneSiteScheduling
    private let siteDataMeter: DataMeting
    private let defaults: UserDefaultsStoring
    
    init(sites: HormoneSiteScheduling, siteDataMeter: DataMeting, defaults: UserDefaultsStoring) {
        self.sites = sites
        self.siteDataMeter = siteDataMeter
        self.defaults = defaults
    }
    
    public func broadcast(nextHormone: Hormonal?) {
        if let mone = nextHormone {
            let name = sites.suggested?.name ?? SiteStrings.newSite
            siteDataMeter.broadcastRelevantHormoneData(
                oldestHormone: mone,
                nextSuggestedSite: name,
                interval: defaults.expirationInterval,
                deliveryMethod: defaults.deliveryMethod
            )
        }
    }
}
