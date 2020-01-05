//
//  PatchDataAdapter.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataEntities {

    private var hormoneMOs: [MOHormone] = []
    private var siteMOs: [MOSite] = []
    private var pillMOs: [MOPill] = []

    private var hormonesInitialized = false
    private var pillsInitialized = false
    private var sitesInitialized = false

    private let logger = CoreDataEntitiesLogger()
    private let saver: EntitiesSaver

    var coreDataStack: PDCoreDataDelegate

    init(coreDataStack: PDCoreDataDelegate) {
        self.coreDataStack = coreDataStack
        saver = EntitiesSaver(coreDataStack)
    }

    func getHormoneById(_ id: UUID?) -> MOHormone? {
        if let id = id {
            if let hormone = hormoneMOs.first(where: { h in h.id == id }) {
                return hormone
            }
            logger.warnForNonExistence(.hormone, id: id.uuidString)
        }
        return nil
    }

    func getStoredHormoneData(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [HormoneStruct] {
        if !hormonesInitialized {
            loadStoredHormones()
        }

        var hormoneStructs: [HormoneStruct] = []
        for managedHormone in hormoneMOs {
            if let hormone = CoreDataEntityAdapter.convertToHormoneStruct(managedHormone) {
                hormoneStructs.append(hormone)
            }
        }

        return hormoneStructs
    }

    func createNewHormone(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> HormoneStruct? {
        if let newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone {
            let id = UUID()
            newManagedHormone.id = id
            hormoneMOs.append(newManagedHormone)
            saver.saveCreateNewEntity(.hormone, id: id.uuidString)
            return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
        }
        logger.errorOnCreation(.hormone)
        return nil
    }

    func pushHormoneData(_ hormoneData: [HormoneStruct]) {
        logger.logPush(.hormone)
        if hormoneData.count == 0 {
            logger.warnForEmptyPush(.hormone)
            return
        }

        for data in hormoneData {
            if let managedHormone = getHormoneById(data.id) {
                managedHormone.date = data.date as NSDate?
                managedHormone.siteNameBackUp = data.siteNameBackUp

                // Set the site
                let managedSiteRelationship = getSiteById(data.siteRelationshipId ?? nil)
                managedHormone.siteRelationship = managedSiteRelationship
            }
        }
        saver.saveFromPush(.hormone)
    }

    func deleteHormoneData(_ hormoneData: [HormoneStruct]) {
        for data in hormoneData {
            if let managedHormone = getHormoneById(data.id) {
                managedHormone.id = nil
                managedHormone.date = nil
                managedHormone.siteNameBackUp = nil
                managedHormone.siteRelationship = nil
                coreDataStack.tryDelete(managedHormone)
                saver.saveFromDelete(.hormone)
            }
        }
    }

    func getPillById(_ id: UUID?) -> MOPill? {
        if let id = id {
            if let pill = pillMOs.first(where: { p in p.id == id }) {
                return pill
            }
            logger.warnForNonExistence(.pill, id: id.uuidString)
        }
        return nil
    }

    func getStoredPillData() -> [PillStruct] {
        if !pillsInitialized {
            loadStoredPills()
        }

        var pillStructs: [PillStruct] = []
        for managedPill in pillMOs {
            if let pill = CoreDataEntityAdapter.convertToPillStruct(managedPill) {
                pillStructs.append(pill)
            }
        }
        return pillStructs
    }

    func createNewPill() -> PillStruct? {
        createNewPill(name: SiteStrings.newSite)
    }

    func createNewPill(name: String) -> PillStruct? {
        if let newManagedPill = coreDataStack.insert(.pill) as? MOPill {
            let id = UUID()
            newManagedPill.id = id
            self.pillMOs.append(newManagedPill)
            saver.saveCreateNewEntity(.pill, id: id.uuidString)
            return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
        }
        logger.errorOnCreation(.pill)
        return nil
    }

    func pushPillData(_ pillData: [PillStruct]) {
        logger.logPush(.pill)
        if pillData.count == 0 {
            logger.warnForEmptyPush(.pill)
            return
        }

        for data in pillData {
            if let managedPill = getPillById(data.id) {
                managedPill.name = data.attributes.name
                managedPill.lastTaken = data.attributes.lastTaken as NSDate?
                managedPill.notify = data.attributes.notify ?? managedPill.notify
                managedPill.timesaday = Int16(data.attributes.timesaday ?? DefaultPillTimesaday)
                managedPill.time1 = data.attributes.time1 as NSDate?
                managedPill.time2 = data.attributes.time2 as NSDate?
                managedPill.timesTakenToday = Int16(data.attributes.timesTakenToday ?? 0)
            }
        }
        saver.saveFromPush(.pill)
    }

    func deletePillData(_ pillData: [PillStruct]) {
        for data in pillData {
            if let managedPill = getPillById(data.id) {
                coreDataStack.tryDelete(managedPill)
                saver.saveFromDelete(.pill)
            }
        }
    }

    func getSiteById(_ id: UUID?) -> MOSite? {
        if let id = id {
            if let site = siteMOs.first(where: { s in s.id == id }) {
                return site
            }
            logger.warnForNonExistence(.site, id: id.uuidString)
            logger.logSites(siteMOs)
        }
        return nil
    }

    func getStoredSiteData(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [SiteStruct] {
        if !sitesInitialized {
            loadStoredSites()
        }

        var siteStructs: [SiteStruct] = []
        for managedSite in siteMOs {
            if let site = CoreDataEntityAdapter.convertToSiteStruct(managedSite) {
                siteStructs.append(site)
            }
        }
        return siteStructs
    }

    func createNewSite(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> SiteStruct? {
        if let newManagedSite = coreDataStack.insert(.site) as? MOSite {
            let id = UUID()
            newManagedSite.id = id
            siteMOs.append(newManagedSite)
            saver.saveCreateNewEntity(.site, id: id.uuidString)
            return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
        }
        logger.errorOnCreation(.site)
        return nil
    }

    func pushSiteData(_ siteData: [SiteStruct]) {
        logger.logPush(.site)
        if siteData.count == 0 {
            logger.warnForEmptyPush(.site)
            return
        }

        for data in siteData {
            if let site = getSiteById(data.id) {
                site.name = data.name
                site.imageIdentifier = data.imageIdentifier
                site.order = Int16(data.order)

                var hormones: [MOHormone] = []
                for hormoneId in data.hormoneRelationshipIds ?? [] {
                    if let hormone = getHormoneById(hormoneId) {
                        hormones.append(hormone)
                    }
                }

                site.hormoneRelationship = Set(hormones) as NSSet
            }
        }
        saver.saveFromPush(.site)
    }

    func deleteSiteData(_ siteData: [SiteStruct]) {
        for data in siteData {
            if let managedSite = getSiteById(data.id) {
                managedSite.name = nil
                managedSite.id = nil
                managedSite.imageIdentifier = nil
                managedSite.order = -1
                pushBackupSiteNameToHormones(deletedSite: managedSite)
                coreDataStack.tryDelete(managedSite)
                saver.saveFromDelete(.site)
            }
        }
    }

    // MARK: - Private

    private func loadStoredHormones() {
        if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
            logger.logEntityCount(hormones.count, for: .hormone)
            hormoneMOs = hormones
            fixHormoneIds()
        } else {
            logger.errorOnCreation(.hormone)
        }
        hormonesInitialized = true
    }

    private func loadStoredPills() {
        if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
            logger.logEntityCount(pills.count, for: .pill)
            pillMOs = pills
            fixPillIds()
        } else {
            logger.errorOnLoad(.pill)
        }
        pillsInitialized = true
    }

    private func loadStoredSites() {
        if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
            logger.logEntityCount(sites.count, for: .site)
            siteMOs = sites
            fixSiteIds()
        } else {
            logger.errorOnLoad(.site)
        }
        sitesInitialized = true
    }

    private func fixHormoneIds() {
        for hormone in hormoneMOs {
            if hormone.id == nil {
                hormone.id = UUID()
            }
        }
    }

    private func fixPillIds() {
        for pill in pillMOs {
            if pill.id == nil {
                pill.id = UUID()
            }
        }
    }

    private func fixSiteIds() {
        for site in siteMOs {
            if site.id == nil {
                site.id = UUID()
            }
        }
    }

    private func pushBackupSiteNameToHormones(deletedSite: MOSite) {
        if let hormoneSet = deletedSite.hormoneRelationship,
           let hormones = Array(hormoneSet) as? [MOHormone] {
            for hormone in hormones {
                hormone.siteNameBackUp = deletedSite.name
            }
        }
        saver.saveFromPush(.hormone)
    }
}
