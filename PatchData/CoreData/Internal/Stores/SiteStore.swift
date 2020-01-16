//
//  SiteStore.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SiteStore: EntityStore, SiteStoring {

    func getStoredSites(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [Bodily] {
        var sites: [Bodily] = []
        let siteDataEntries = entities.getManagedSiteData()
        for siteData in siteDataEntries {
            let site = Site(siteData: siteData, expirationInterval: expiration, deliveryMethod: method)
            sites.append(site)
        }
        return sites
    }

    func createNewSite(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool) -> Bodily? {
        if let newSiteDataFromStore = entities.createNewManagedSite(doSave: doSave) {
            return Site(siteData: newSiteDataFromStore, expirationInterval: expiration, deliveryMethod: method)
        }
        return nil
    }

    func delete(_ site: Bodily) {
        entities.deleteManagedSiteData([CoreDataEntityAdapter.convertToSiteStruct(site)])
    }

    func pushLocalChangesToBeSaved(_ sites: [Bodily]) {
        guard sites.count > 0 else { return }
        let siteData = sites.map { s in CoreDataEntityAdapter.convertToSiteStruct(s) }
        self.pushLocalChangesToBeSaved(siteData)
    }
    
    func getSiteHormones(siteId: UUID) -> [HormoneStruct] {
        if let site = entities.getManagedSite(by: siteId) {
            var hormones: [HormoneStruct] = []
            guard let relatedHormones = site.hormoneRelationship else {
                return hormones
            }
            for ele in relatedHormones {
                if let managedHormone = ele as? MOHormone, let hormoneId = managedHormone.id {
                    let hormoneData = HormoneStruct(
                        hormoneId,
                        site.id,
                        site.name,
                        managedHormone.date as Date?,
                        managedHormone.siteNameBackUp
                    )
                    hormones.append(hormoneData)
                }
            }
            return hormones
        }
        return []
    }

    private func pushLocalChangesToBeSaved(_ siteData: [SiteStruct]) {
        entities.pushSiteDataToManagedContext(siteData)
    }
}
