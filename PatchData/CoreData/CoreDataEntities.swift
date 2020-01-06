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

    private static var hormoneMOs: [MOHormone] = []
    private static var siteMOs: [MOSite] = []
    private static var pillMOs: [MOPill] = []

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

    func getHormone(by id: UUID) -> MOHormone? {
        if let hormone = CoreDataEntities.hormoneMOs.first(where: { h in h.id == id }) {
            return hormone
        }
        logger.warnForNonExistence(.hormone, id: id.uuidString)
        return nil
    }

    func getStoredHormoneData(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [HormoneStruct] {
        if !hormonesInitialized {
            loadStoredHormones()
        }

        var hormoneStructs: [HormoneStruct] = []
        for managedHormone in CoreDataEntities.hormoneMOs {
            if let hormone = CoreDataEntityAdapter.convertToHormoneStruct(managedHormone) {
                hormoneStructs.append(hormone)
            }
        }

        return hormoneStructs
    }

    func createNewHormone(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool=true) -> HormoneStruct? {
        if let newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone {
            let id = UUID()
            logger.logCreate(.hormone, id: id.uuidString)
            newManagedHormone.id = id
            CoreDataEntities.hormoneMOs.append(newManagedHormone)
            if doSave {
                saver.saveCreateNewEntity(.hormone)
            }
            return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
        }
        logger.errorOnCreation(.hormone)
        return nil
    }

    func pushHormoneData(_ hormoneData: [HormoneStruct], doSave: Bool=true) {
        logger.logPush(.hormone)
        if hormoneData.count == 0 {
            logger.warnForEmptyPush(.hormone)
            return
        }

        for data in hormoneData {
            if let managedHormone = getHormone(by: data.id) {
                managedHormone.date = data.date as NSDate?
                managedHormone.siteNameBackUp = data.siteNameBackUp

                // Set the site
                if let siteId = data.siteRelationshipId {
                    let managedSiteRelationship = getSite(by: siteId)
                    managedHormone.siteRelationship = managedSiteRelationship
                }
            }
        }
        if doSave {
            saver.saveFromPush(.hormone)
        }
    }

    func deleteHormoneData(_ hormoneData: [HormoneStruct], doSave: Bool=true) {
        for data in hormoneData {
            if let managedHormone = getHormone(by: data.id) {
                managedHormone.id = nil
                managedHormone.date = nil
                managedHormone.siteNameBackUp = nil
                managedHormone.siteRelationship = nil
                coreDataStack.tryDelete(managedHormone)
                if doSave {
                    saver.saveFromDelete(.hormone)
                }
            }
        }
    }

    func getPill(by id: UUID) -> MOPill? {
        if let pill = CoreDataEntities.pillMOs.first(where: { p in p.id == id }) {
            return pill
        }
        logger.warnForNonExistence(.pill, id: id.uuidString)
        return nil
    }

    func getStoredPillData() -> [PillStruct] {
        if !pillsInitialized {
            loadStoredPills()
        }

        var pillStructs: [PillStruct] = []
        for managedPill in CoreDataEntities.pillMOs {
            if let pill = CoreDataEntityAdapter.convertToPillStruct(managedPill) {
                pillStructs.append(pill)
            }
        }
        return pillStructs
    }

    func createNewPill(doSave: Bool=true) -> PillStruct? {
        createNewPill(name: SiteStrings.newSite, doSave: doSave)
    }

    func createNewPill(name: String, doSave: Bool=true) -> PillStruct? {
        if let newManagedPill = coreDataStack.insert(.pill) as? MOPill {
            let id = UUID()
            logger.logCreate(.pill, id: id.uuidString)
            newManagedPill.id = id
            CoreDataEntities.pillMOs.append(newManagedPill)
            if doSave {
                saver.saveCreateNewEntity(.pill)
            }
            return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
        }
        logger.errorOnCreation(.pill)
        return nil
    }

    func pushPillData(_ pillData: [PillStruct], doSave: Bool=true) {
        logger.logPush(.pill)
        if pillData.count == 0 {
            logger.warnForEmptyPush(.pill)
            return
        }

        for data in pillData {
            if let managedPill = getPill(by: data.id) {
                managedPill.name = data.attributes.name
                managedPill.lastTaken = data.attributes.lastTaken as NSDate?
                managedPill.notify = data.attributes.notify ?? managedPill.notify
                managedPill.timesaday = Int16(data.attributes.timesaday ?? DefaultPillTimesaday)
                managedPill.time1 = data.attributes.time1 as NSDate?
                managedPill.time2 = data.attributes.time2 as NSDate?
                managedPill.timesTakenToday = Int16(data.attributes.timesTakenToday ?? 0)
            }
        }
        if doSave {
            saver.saveFromPush(.pill)
        }
    }

    func deletePillData(_ pillData: [PillStruct], doSave: Bool=true) {
        for data in pillData {
            if let managedPill = getPill(by: data.id) {
                coreDataStack.tryDelete(managedPill)
                if doSave {
                    saver.saveFromDelete(.pill)
                }
            }
        }
    }

    func getSite(by id: UUID) -> MOSite? {
        if let site = CoreDataEntities.siteMOs.first(where: { s in s.id == id }) {
            return site
        }
        logger.warnForNonExistence(.site, id: id.uuidString)
        logger.logSites(CoreDataEntities.siteMOs)
        return nil
    }

    func getStoredSiteData(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [SiteStruct] {
        if !sitesInitialized {
            loadStoredSites()
        }

        var siteStructs: [SiteStruct] = []
        for managedSite in CoreDataEntities.siteMOs {
            if let site = CoreDataEntityAdapter.convertToSiteStruct(managedSite) {
                siteStructs.append(site)
            }
        }
        return siteStructs
    }

    func createNewSite(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool=true) -> SiteStruct? {
        if let newManagedSite = coreDataStack.insert(.site) as? MOSite {
            let id = UUID()
            logger.logCreate(.site, id: id.uuidString)
            newManagedSite.id = id
            CoreDataEntities.siteMOs.append(newManagedSite)
            if doSave {
                saver.saveCreateNewEntity(.site)
            }
            return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
        }
        logger.errorOnCreation(.site)
        return nil
    }

    func pushSiteData(_ siteData: [SiteStruct], doSave: Bool=true) {
        logger.logPush(.site)
        if siteData.count == 0 {
            logger.warnForEmptyPush(.site)
            return
        }

        for data in siteData {
            if let site = getSite(by: data.id) {
                site.name = data.name
                site.imageIdentifier = data.imageIdentifier
                site.order = Int16(data.order)

                var hormones: [MOHormone] = []
                for hormoneId in data.hormoneRelationshipIds ?? [] {
                    if let hormone = getHormone(by: hormoneId) {
                        hormones.append(hormone)
                    }
                }

                site.hormoneRelationship = Set(hormones) as NSSet
            }
        }
        if doSave {
            saver.saveFromPush(.site)
        }
    }

    func deleteSiteData(_ siteData: [SiteStruct], doSave: Bool=true) {
        for data in siteData {
            if let managedSite = getSite(by: data.id) {
                managedSite.name = nil
                managedSite.id = nil
                managedSite.imageIdentifier = nil
                managedSite.order = -1
                pushBackupSiteNameToHormones(deletedSite: managedSite)
                coreDataStack.tryDelete(managedSite)
                if doSave {
                    saver.saveFromDelete(.site)
                }
            }
        }
    }

    // MARK: - Private

    private func loadStoredHormones() {
        if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
            logger.logEntityCount(hormones.count, for: .hormone)
            CoreDataEntities.hormoneMOs = hormones
            fixHormoneIds()
        } else {
            logger.errorOnCreation(.hormone)
        }
        hormonesInitialized = true
    }

    private func loadStoredPills() {
        if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
            logger.logEntityCount(pills.count, for: .pill)
            CoreDataEntities.pillMOs = pills
            fixPillIds()
        } else {
            logger.errorOnLoad(.pill)
        }
        pillsInitialized = true
    }

    private func loadStoredSites() {
        if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
            logger.logEntityCount(sites.count, for: .site)
            CoreDataEntities.siteMOs = sites
            fixSiteIds()
        } else {
            logger.errorOnLoad(.site)
        }
        sitesInitialized = true
    }

    private func fixHormoneIds() {
        for hormone in CoreDataEntities.hormoneMOs {
            if hormone.id == nil {
                hormone.id = UUID()
            }
        }
    }

    private func fixPillIds() {
        for pill in CoreDataEntities.pillMOs {
            if pill.id == nil {
                pill.id = UUID()
            }
        }
    }

    private func fixSiteIds() {
        for site in CoreDataEntities.siteMOs {
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
