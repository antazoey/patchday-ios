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

    func getStoredHormoneData(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [HormoneStruct] {
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
}
