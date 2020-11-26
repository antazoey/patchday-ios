//
//  HormoneDataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class HormoneDataSharer: HormoneDataSharing {

    private let base: UserDefaultsProtocol
    private let sites: SiteScheduling
    private let settings: UserDefaultsReading

    init(baseSharer: UserDefaultsProtocol, sites: SiteScheduling, settings: UserDefaultsReading) {
        self.base = baseSharer
        self.sites = sites
        self.settings = settings
    }

    public func share(nextHormone: Hormonal) {
        let method = settings.deliveryMethod
        let interval = settings.expirationInterval
        let nextSite = sites.suggested

        let name: String = {
            switch method.value {
                case .Patches: return sites.suggested?.name
                case .Injections: return nextSite?.name
                case .Gel: return nextSite?.name
            }
        }() ?? SiteStrings.NewSite

        shareRelevantHormoneData(
            oldestHormone: nextHormone,
            displayedSiteName: name,
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
        base.set(displayedSiteName, for: SharedDataKey.NextHormoneSiteName.rawValue)
        base.set(oldestHormone.date, for: SharedDataKey.NextHormoneDate.rawValue)
    }
}
