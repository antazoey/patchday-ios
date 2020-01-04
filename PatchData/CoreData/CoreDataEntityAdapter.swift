//
// Created by Juliya Smith on 12/22/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataEntityAdapter {

    private static let log = PDLog<CoreDataEntityAdapter>()

    static func convertToHormoneStruct(_ hormone: MOHormone) -> HormoneStruct? {
        if let id = hormone.id {
            return HormoneStruct(
                hormone.siteRelationship?.id,
                id,
                hormone.siteRelationship?.name,
                hormone.date as Date?,
                hormone.siteNameBackUp
            )
        } else {
            log.error("Failure converting managed \(PDEntity.hormone.rawValue) to DTO struct. Missing ID.")
            return nil
        }
    }

    static func convertToHormoneStruct(_ hormone: Hormonal) -> HormoneStruct {
        HormoneStruct(hormone.siteId, hormone.id, hormone.siteName, hormone.date, hormone.siteNameBackUp)
    }

    static func convertToPillStruct(_ pill: MOPill) -> PillStruct? {
        if let id = pill.id {
            let attributes = PillAttributes(
                name: pill.name ?? PDStrings.PlaceholderStrings.newPill,
                timesaday: Int(pill.timesaday),
                time1: pill.time1 as Date?,
                time2: pill.time2 as Date?,
                notify: pill.notify,
                timesTakenToday: Int(pill.timesTakenToday),
                lastTaken: pill.lastTaken as Date?
            )
            return PillStruct(id, attributes)
        } else {
            log.error("Failure converting managed \(PDEntity.pill.rawValue) to DTO struct. Missing ID.")
            return nil
        }
    }

    static func convertToPillStruct(_ pill: Swallowable) -> PillStruct {
        PillStruct(pill.id, pill.attributes)
    }

    static func convertToSiteStruct(_ site: MOSite) -> SiteStruct? {
        if let id = site.id {
            var ids: [UUID] = []
            for element in site.hormoneRelationship ?? NSSet() {
                if let hormone = element as? MOHormone, let id = hormone.id {
                    ids.append(id)
                }
            }
            return SiteStruct(id, ids, site.imageIdentifier, site.name, Int(site.order))
        } else {
            log.error("Failure converting managed \(PDEntity.site.rawValue) to DTO struct. Missing ID.")
            return nil
        }
    }

    static func convertToSiteStruct(_ site: Bodily) -> SiteStruct {
        SiteStruct(site.id, site.hormoneIds, site.imageId, site.name, site.order)
    }
}
