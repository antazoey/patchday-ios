//
//  PatchDataAdapter.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


extension PDCoreData {

    static func createPill() -> Swallowable? {
        createPill(name: SiteStrings.newSite)
    }
    
    static func createPill(name: String) -> Swallowable? {
        if let pill = insert(.pill) as? MOPill {
            return Pill(pill: pill, name: name)
        }
        return nil
    }

    static func createHormones(
        expirationInterval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethod
    ) -> [Hormonal] {
        var hormones: [Hormonal] = []
        if let mos = loadMOs(for: .hormone) {
            for mo in mos {
                if let mone = mo as? MOHormone {
                    let pdMone = Hormone(
                        hormone: mone,
                        interval: expirationInterval,
                        deliveryMethod: deliveryMethod
                    )
                   hormones.append(pdMone)
                }
            }
        }
        return hormones
    }

    static func createHormone(
        expirationInterval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethod
    ) -> Hormonal? {
        if let hormone = insert(.hormone) as? MOHormone {
            return Hormone(
                hormone: hormone,
                interval: expirationInterval,
                deliveryMethod: deliveryMethod
            )
        }
        return nil
    }

    static func createPills() -> [Swallowable] {
        var pills: [Swallowable] = []
        if let mos = loadMOs(for: .pill) {
            for mo in mos {
                if let moPill = mo as? MOPill {
                    let name = moPill.name ?? PDStrings.PlaceholderStrings.newPill
                    let pdPill = Pill(pill: moPill, name: name)
                    pills.append(pdPill)
                }
            }
        }
        return pills
    }

    static func createSite(
        expirationIntervalUD: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethod
    ) -> Bodily? {
        if let site = insert(.site) as? MOSite {
            return Site(
                moSite: site,
                globalExpirationInterval: expirationIntervalUD,
                deliveryMethod: deliveryMethod
            )
        }
        return nil
    }

    static func createSites(
        expirationIntervalUD: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethod
    ) -> [Bodily] {
        var sites: [Bodily] = []
        if let mos = loadMOs(for: .site) {
            for mo in mos {
                if let moSite = mo as? MOSite {
                    let pdSite = Site(
                        moSite: moSite,
                        globalExpirationInterval: expirationIntervalUD,
                        deliveryMethod: deliveryMethod
                    )
                    sites.append(pdSite)
                }
            }
        }
        return sites
    }
}
