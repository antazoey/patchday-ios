//
//  PatchDataAdapter.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

extension PatchData {
    
    static func createHormones(expirationInterval: ExpirationIntervalUD,
                                deliveryMethod: DeliveryMethod) -> [Hormonal] {
        var hormones: [Hormonal] = []
        if let mos = loadMOs(for: .hormone) {
            for mo in mos {
                if let mone = mo as? MOHormone {
                    let pdMone = PDHormone(
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
    
    static func createPills() -> [Swallowable] {
        var pills: [Swallowable] = []
        if let mos = loadMOs(for: .pill) {
            for mo in mos {
                if let moPill = mo as? MOPill {
                    let name = moPill.name ?? PDStrings.PlaceholderStrings.newPill
                    let pdPill = PDPill(pill: moPill, name: name)
                    pills.append(pdPill)
                }
            }
        }
        return pills
    }
    
    static func createSites(expirationIntervalUD: ExpirationIntervalUD,
                            deliveryMethod: DeliveryMethod) -> [Bodily] {
        var sites: [Bodily] = []
        if let mos = loadMOs(for: .site) {
            for mo in mos {
                if let moSite = mo as? MOSite {
                    let pdSite = PDSite(
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
