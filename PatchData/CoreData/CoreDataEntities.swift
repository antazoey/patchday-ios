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

    init(coreDataStack: PDCoreDataDelegate) {
        self.coreDataStack = coreDataStack
    }

    func getHormoneById(_ id: UUID?) -> MOHormone? {
        hormoneMOs.first(where: { h in h.id == id })
    }

    func getStoredHormoneData(
        expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod
    ) -> [HormoneStruct] {
        if !hormonesInitialized {
            loadStoredHormones()
        }

        var hormoneStructs: [HormoneStruct] = []
        for managedHormone in hormoneMOs {
            hormoneStructs.append(CoreDataEntityAdapter.convertToHormoneStruct(managedHormone))
        }

        return hormoneStructs
    }

    func createNewHormone(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> HormoneStruct? {
        if let newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone {
            hormoneMOs.append(newManagedHormone)
            return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
        }
        return nil
    }

    func pushHormoneData(_ hormoneData: [HormoneStruct]) {
        for data in hormoneData {
            if let managedHormone = getHormoneById(data.id) {
                managedHormone.date = data.date as NSDate?
                managedHormone.siteNameBackUp = data.siteNameBackUp

                // Set the site
                let managedSiteRelationship = getSiteById(data.siteRelationshipId ?? nil)
                managedHormone.siteRelationship = managedSiteRelationship
            }
        }
        coreDataStack.save()
    }

    func deleteHormoneData(_ hormoneData: [HormoneStruct]) {
        for data in hormoneData {
            if let managedHormone = getHormoneById(data.id) {
                managedHormone.id = nil
                managedHormone.date = nil
                managedHormone.siteNameBackUp = nil
                managedHormone.siteRelationship = nil
                coreDataStack.tryDelete(managedHormone)
                coreDataStack.save()
            }
        }
    }

    func getPillById(_ id: UUID?) -> MOPill? {
        pillMOs.first(where: { p in p.id == id })
    }

    func getStoredPillData() -> [PillStruct] {
        if !pillsInitialized {
            loadStoredPills()
        }

        var pillStructs: [PillStruct] = []
        for managedPill in pillMOs {
            let pill = CoreDataEntityAdapter.convertToPillStruct(managedPill)
            pillStructs.append(pill)
        }
        return pillStructs
    }

    func createNewPill() -> PillStruct? {
        createNewPill(name: SiteStrings.newSite)
    }

    func createNewPill(name: String) -> PillStruct? {
        if let newManagedPill = coreDataStack.insert(.pill) as? MOPill {
            self.pillMOs.append(newManagedPill)
            return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
        }
        return nil
    }

    func pushPillData(_ pillData: [PillStruct]) {
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
        coreDataStack.save()
    }

    func deletePillData(_ pillData: [PillStruct]) {
        for data in pillData {
            if let managedPill = getPillById(data.id) {
                coreDataStack.tryDelete(managedPill)
                coreDataStack.save()
            }
        }
    }

    func getSiteById(_ id: UUID?) -> MOSite? {
        siteMOs.first(where: { s in s.id == id })
    }

    func getStoredSiteData(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [SiteStruct] {
        if !sitesInitialized {
            loadStoredSites()
        }

        var siteStructs: [SiteStruct] = []
        for managedSite in siteMOs {
            let siteStruct = CoreDataEntityAdapter.convertToSiteStruct(managedSite)
            siteStructs.append(siteStruct)
        }
        return siteStructs
    }

    func createNewSite(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> SiteStruct? {
        if let newManagedSite = coreDataStack.insert(.site) as? MOSite {
            siteMOs.append(newManagedSite)
            return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
        }
        return nil
    }

    func pushSiteData(_ siteData: [SiteStruct]) {
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
        coreDataStack.save()
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
                coreDataStack.save()
            }
        }
    }

    // MARK: - Private

    private func loadStoredHormones() {
        if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
            hormoneMOs = hormones
        }
        hormonesInitialized = true
    }

    private func loadStoredPills() {
        if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
            pillMOs = pills
        }
        pillsInitialized = true
    }

    private func loadStoredSites() {
        if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
            siteMOs = sites
        }
        sitesInitialized = true
    }

    private func pushBackupSiteNameToHormones(deletedSite: MOSite) {
        if let hormoneSet = deletedSite.hormoneRelationship,
           let hormones = Array(hormoneSet) as? [MOHormone] {
            for hormone in hormones {
                hormone.siteNameBackUp = deletedSite.name
            }
        }
        coreDataStack.save()
    }
}
