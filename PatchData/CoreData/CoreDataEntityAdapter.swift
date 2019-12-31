//
// Created by Juliya Smith on 12/22/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataEntityAdapter {

    static func convertToHormoneStruct(_ hormone: MOHormone) -> HormoneStruct {
        HormoneStruct(hormone.siteRelationship?.id, hormone.id, hormone.date, hormone.siteNameBackUp)
    }

    static func convertToPillStruct(_ pill: MOPill) -> PillStruct {
        let attributes = PillAttributes(
            name: pill.name ?? PDStrings.PlaceholderStrings.newPill,
            timesaday: Int(pill.timesaday),
            time1: pill.time1 as Date?,
            time2: pill.time2 as Date?,
            notify: pill.notify,
            timesTakenToday: Int(pill.timesTakenToday),
            lastTaken: pill.lastTaken as Date?
        )
        return PillStruct(pill.id ?? UUID(), attributes)
    }

    static func convertToSiteStruct(_ site: MOSite) -> SiteStruct {
        var ids: [UUID] = []
        for element in site.hormoneRelationship ?? NSSet() {
            if let hormone = element as? MOHormone, let id = hormone.id {
                ids.append(id)
            }
        }
        return SiteStruct(ids, site.imageIdentifier, site.name, Int(site.order))
    }
}
