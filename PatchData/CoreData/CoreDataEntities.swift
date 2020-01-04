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

    var coreDataStack: PDCoreDataDelegate

    private let log = PDLog<CoreDataEntities>()

    init(coreDataStack: PDCoreDataDelegate) {
        self.coreDataStack = coreDataStack
    }

    func getHormoneById(_ id: UUID?) -> MOHormone? {
        if id == nil {
            return nil
        }

        if let hormone = hormoneMOs.first(where: { h in h.id == id }) {
            return hormone
        }
        log.warn("No managed \(PDEntity.hormone.rawValue) exists for ID \(id!)")
        return nil
    }

    func getStoredHormoneData(
        expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod
    ) -> [HormoneStruct] {
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

    func createNewHormone(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> HormoneStruct? {
        if let newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone {
            coreDataStack.save(saverName: "Create new \(PDEntity.hormone.rawValue)")
            let id = UUID()
            newManagedHormone.id = id
            log.info("Creating new \(PDEntity.hormone.rawValue) with ID \(id)")
            hormoneMOs.append(newManagedHormone)
            return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
        }
        log.error("Failed creating new \(PDEntity.hormone.rawValue)")
        return nil
    }

    func pushHormoneData(_ hormoneData: [HormoneStruct]) {
        if hormoneData.count == 0 {
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
        coreDataStack.save(saverName: "Hormone save")
    }

    func deleteHormoneData(_ hormoneData: [HormoneStruct]) {
        for data in hormoneData {
            if let managedHormone = getHormoneById(data.id) {
                managedHormone.id = nil
                managedHormone.date = nil
                managedHormone.siteNameBackUp = nil
                managedHormone.siteRelationship = nil
                coreDataStack.tryDelete(managedHormone)
                coreDataStack.save(saverName: "Hormone delete")
            }
        }
    }

    func getPillById(_ id: UUID?) -> MOPill? {
        if id == nil {
            return nil
        }
        if let pill = pillMOs.first(where: { p in p.id == id }) {
            return pill
        }

        log.warn("No managed \(PDEntity.pill.rawValue) exists for ID \(id!)")
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
            coreDataStack.save(saverName: "Create new \(PDEntity.pill.rawValue)")
            let id = UUID()
            newManagedPill.id = id
            log.info("Creating new \(PDEntity.pill.rawValue) with ID \(id)")
            self.pillMOs.append(newManagedPill)
            return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
        }
        log.error("Failed creating new \(PDEntity.pill.rawValue)")
        return nil
    }

    func pushPillData(_ pillData: [PillStruct]) {
        if pillData.count == 0 {
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
        coreDataStack.save(saverName: "Pill save")
    }

    func deletePillData(_ pillData: [PillStruct]) {
        for data in pillData {
            if let managedPill = getPillById(data.id) {
                coreDataStack.tryDelete(managedPill)
                coreDataStack.save(saverName: "Pill delete")
            }
        }
    }

    func getSiteById(_ id: UUID?) -> MOSite? {
        if id == nil {
            return nil
        }

        if let site = siteMOs.first(where: { s in s.id == id }) {
            return site
        }
        log.warn("No managed \(PDEntity.site.rawValue) exists for ID \(id!)")
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
            coreDataStack.save(saverName: "Create new \(PDEntity.site.rawValue)")
            let id = UUID()
            newManagedSite.id = id
            log.info("Creating new \(PDEntity.site.rawValue) with ID \(id)")
            siteMOs.append(newManagedSite)
            return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
        }
        log.error("Failed creating new \(PDEntity.site.rawValue)")
        return nil
    }

    func pushSiteData(_ siteData: [SiteStruct]) {
        if siteData.count == 0 {
            return
        }

        for data in siteData {
            if let site = getSiteById(data.id) {
                site.name = data.name
                site.imageIdentifier = data.imageIdentifier

                var hormones: [MOHormone] = []
                for hormoneId in data.hormoneRelationshipIds ?? [] {
                    if let hormone = getHormoneById(hormoneId) {
                        hormones.append(hormone)
                    }
                }

                site.hormoneRelationship = Set(hormones) as NSSet
            }
        }
        coreDataStack.save(saverName: "Site save")
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
                coreDataStack.save(saverName: "Site delete")
            }
        }
    }

    // MARK: - Private

    private func loadStoredHormones() {
        if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
            logEntityCount(hormones.count, for: .hormone)
            hormoneMOs = hormones
            fixHormoneIds()
        } else {
            log.error("Failed to load hormones from Core Data")
        }
        hormonesInitialized = true
    }

    private func loadStoredPills() {
        if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
            logEntityCount(pills.count, for: .pill)
            pillMOs = pills
            fixPillIds()
        } else {
            log.error("Failed to load pills from Core Data")
        }
        pillsInitialized = true
    }

    private func loadStoredSites() {
        if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
            logEntityCount(sites.count, for: .site)
            siteMOs = sites
            fixSiteIds()
        } else {
            log.error("Failed to load sites from Core Data")
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
        coreDataStack.save(saverName: "Saving from pushing backup site names to hormones")
    }

    private func logEntityCount(_ count: Int, for entity: PDEntity) {
        log.info("Loading \(count) \(entity.rawValue)(s) from Core Data")
    }
}
