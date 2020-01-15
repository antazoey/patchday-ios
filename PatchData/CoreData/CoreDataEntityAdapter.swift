//
// Created by Juliya Smith on 12/22/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataEntityAdapter {

    private static let log = PDLog<CoreDataEntityAdapter>()
    
    // MARK: - Hormones

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
    
    static func applyHormoneData(_ hormoneData: HormoneStruct, to hormone: inout MOHormone) {
        if let date = hormoneData.date  {
            hormone.date = date as NSDate
        }
        if let siteNameBackUp = hormoneData.siteNameBackUp {
            hormone.siteNameBackUp = siteNameBackUp
        }
    }
    
    // MARK: - Pills

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
    
    static func applyPillData(_ pillData: PillStruct, to pill: inout MOPill) {
        if let name = pillData.attributes.name {
            pill.name = name
        }
        if let lastTaken = pillData.attributes.lastTaken {
            pill.lastTaken = lastTaken as NSDate
        }
        if let notify = pillData.attributes.notify {
            pill.notify = notify
        }
        if let times = pillData.attributes.timesaday {
            pill.timesaday = Int16(times)
        }
        if let time1 = pillData.attributes.time1 {
            pill.time1 = time1 as NSDate
        }
        if let time2 = pillData.attributes.time2 {
            pill.time2 = time2 as NSDate
        }
        if let timesTaken = pillData.attributes.timesTakenToday {
            pill.timesTakenToday = Int16(timesTaken)
        }
    }
    
    // MARK: - Sites

    static func convertToSiteStruct(_ site: MOSite) -> SiteStruct? {
        if let id = site.id {
            var relatedHormoneIds: [UUID] = []
            if let relationship = site.hormoneRelationship {
                for element in relationship {
                    if let hormone = element as? MOHormone, let hormoneId = hormone.id {
                        relatedHormoneIds.append(hormoneId)
                    }
                }
            }
            return SiteStruct(id, relatedHormoneIds, site.imageIdentifier, site.name, Int(site.order))
        } else {
            log.error("Failure converting managed \(PDEntity.site.rawValue) to DTO struct. Missing ID.")
            return nil
        }
    }

    static func convertToSiteStruct(_ site: Bodily) -> SiteStruct {
        SiteStruct(site.id, site.hormoneIds, site.imageId, site.name, site.order)
    }
    
    static func applySiteData(_ siteData: SiteStruct, to site: inout MOSite) {
        if let name = siteData.name {
            site.name = name
        }
        if let id = siteData.imageIdentifier {
            site.imageIdentifier = id
        }
        if siteData.order >= 0 {
            site.order = Int16(siteData.order)
        }
    }
}
