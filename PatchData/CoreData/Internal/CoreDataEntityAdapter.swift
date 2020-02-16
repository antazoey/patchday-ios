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
        guard let hormoneId = hormone.id else {
            log.error("Failure converting managed \(PDEntity.hormone.rawValue) to DTO struct. Missing ID.")
            return nil
        }
        return createHormoneStruct(hormone, id: hormoneId)
    }

    static func convertToHormoneStruct(_ hormone: Hormonal) -> HormoneStruct {
        HormoneStruct(hormone.id, hormone.siteId, hormone.siteName, hormone.date, hormone.siteNameBackUp)
    }
    
    static func applyHormoneData(_ hormoneData: HormoneStruct, to hormone: inout MOHormone) {
        if let date = hormoneData.date as NSDate?, date != hormone.date {
            hormone.date = date
        }
        if let siteNameBackUp = hormoneData.siteNameBackUp, siteNameBackUp != hormone.siteNameBackUp {
            hormone.siteNameBackUp = siteNameBackUp
        }
    }
    
    // MARK: - Pills

    static func convertToPillStruct(_ pill: MOPill) -> PillStruct? {
        guard let pillId = pill.id else {
            log.error("Failure converting managed \(PDEntity.pill.rawValue) to DTO struct. Missing ID.")
            return nil
        }
        
        let attributes = createPillAttributes(pill)
        return PillStruct(pillId, attributes)
    }

    static func convertToPillStruct(_ pill: Swallowable) -> PillStruct {
        PillStruct(pill.id, pill.attributes)
    }
    
    static func applyPillData(_ pillData: PillStruct, to pill: inout MOPill) {
        if let name = pillData.attributes.name, name != pill.name {
            pill.name = name
        }
        if let lastTaken = pillData.attributes.lastTaken as NSDate?, lastTaken != pill.lastTaken {
               pill.lastTaken = lastTaken
        }
        if let notify = pillData.attributes.notify, notify != pill.notify {
            pill.notify = notify
        }
        if let timesaday = pillData.attributes.timesaday, timesaday != pill.timesaday {
            pill.timesaday = Int16(timesaday)
        }
        if let time1 = pillData.attributes.time1 as NSDate?, time1 != pill.time1 {
            pill.time1 = time1
        }
        if let time2 = pillData.attributes.time2 as NSDate?, time2 != pill.time2 {
            pill.time2 = time2
        }
        if let timesTaken = pillData.attributes.timesTakenToday, timesTaken != pill.timesTakenToday {
            pill.timesTakenToday = Int16(timesTaken)
        }
    }
    
    // MARK: - Sites

    static func convertToSiteStruct(_ site: MOSite) -> SiteStruct? {
        guard let siteId = site.id else {
            log.error("Failure converting managed \(PDEntity.site.rawValue) to DTO struct. Missing ID.")
            return nil
        }
        let relatedHormoneIds = extractHormoneIds(site)
        return SiteStruct(siteId, relatedHormoneIds, site.imageIdentifier, site.name, Int(site.order))
    }

    static func convertToSiteStruct(_ site: Bodily) -> SiteStruct {
        SiteStruct(site.id, site.hormoneIds, site.imageId, site.name, site.order)
    }
    
    static func applySiteData(_ siteData: SiteStruct, to site: inout MOSite) {
        if let name = siteData.name, name != site.name {
            site.name = name
        }
        if let imageId = siteData.imageIdentifier, imageId != site.imageIdentifier {
            site.imageIdentifier = imageId
        }
        if siteData.order >= 0, siteData.order != site.order {
            site.order = Int16(siteData.order)
        }
    }
    
    // MARK: - Private
    
    private static func createHormoneStruct(_ hormone: MOHormone, id: UUID) -> HormoneStruct {
        HormoneStruct(
            id,
            hormone.siteRelationship?.id,
            hormone.siteRelationship?.name,
            hormone.date as Date?,
            hormone.siteNameBackUp
        )
    }
    
    private static func extractHormoneIds(_ site: MOSite) -> [UUID] {
        var relatedHormoneIds: [UUID] = []
        if let relationship = site.hormoneRelationship {
            for element in relationship {
                if let hormone = element as? MOHormone, let hormoneId = hormone.id {
                    relatedHormoneIds.append(hormoneId)
                }
            }
        }
        return relatedHormoneIds
    }
    
    private static func createPillAttributes(_ pill: MOPill) -> PillAttributes {
        return PillAttributes(
            name: pill.name ?? PillStrings.NewPill,
            timesaday: Int(pill.timesaday),
            time1: pill.time1 as Date?,
            time2: pill.time2 as Date?,
            notify: pill.notify,
            timesTakenToday: Int(pill.timesTakenToday),
            lastTaken: pill.lastTaken as Date?
        )
    }
}
