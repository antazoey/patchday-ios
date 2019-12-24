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

    private var hormoneMOs: [MOHormone]
    private var siteMOs: [MOSite]
    private var pillMOs: [MOPill]

    private var hormonesInitialized = false
    private var pillsInitialized = false
    private var sitesInitialized = false

    var coreDataStack: PDCoreDataDelegate

    init(coreDataStack: PDCoreDataDelegate) {
        self.coreDataStack = coreDataStack
    }

    func getStoredHormones(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [HormoneStruct] {
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
        if let hormone = coreDataStack.insert(.hormone) as? MOHormone {
            hormoneMOs.append(hormone)
            return CoreDataEntityAdapter.convertToHormoneStruct(hormone)
        }
        return nil
    }

    func getStoredPills() -> [PillStruct] {
        if !pillsInitialized {
            loadStoredPills()
        }

        var pillStructs: [PillStruct] = []
        for managedPill in pillMOs {
            let name = managedPill.name ?? PDStrings.PlaceholderStrings.newPill
            let pill = PillStruct(name)
                pillStructs.append(pdPill)
            }
        }
        return pillStructs
    }

    func createNewPill() -> PillStruct? {
        createNewPill(name: SiteStrings.newSite)
    }

    func createNewPill(name: String) -> PillStruct? {
        if let pill = coreDataStack.insert(.pill) as? MOPill {
            return Pill(pill: pill, name: name)
        }
        return nil
    }

    func getStoredSites(expirationIntervalUD: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [SiteStruct] {
        var sites: [Bodily] = []
        if let mos = coreDataStack.getManagedObjects(for: .site) {
            for mo in mos {
                if let moSite = mo as? MOSite {
                    let pdSite = Site(
                        moSite: moSite,
                        expirationInterval: expirationIntervalUD,
                        deliveryMethod: deliveryMethod
                    )
                    sites.append(pdSite)
                }
            }
        }
        return sites
    }

    func createNewSite(expirationIntervalUD: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> SiteStruct? {
        if let site = coreDataStack.insert(.site) as? MOSite {
            return Site(
                moSite: site,
                expirationInterval: expirationIntervalUD,
                deliveryMethod: deliveryMethod
            )
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
