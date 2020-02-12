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

    func getStoredSites() -> [Bodily] {
        var sites: [Bodily] = []
        let siteDataEntries = entities.getManagedSiteData()
        for siteData in siteDataEntries {
            let site = Site(siteData: siteData)
            sites.append(site)
        }
        return sites
    }

    func createNewSite(doSave: Bool) -> Bodily? {
        if let newSiteDataFromStore = entities.createNewManagedSite(doSave: doSave) {
            return Site(siteData: newSiteDataFromStore)
        }
        return nil
    }

    func delete(_ site: Bodily) {
        entities.deleteManagedSiteData([CoreDataEntityAdapter.convertToSiteStruct(site)])
    }

    func pushLocalChangesToManagedContext(_ sites: [Bodily], doSave: Bool) {
        guard sites.count > 0 else { return }
        let siteData = sites.map { s in CoreDataEntityAdapter.convertToSiteStruct(s) }
        self.pushLocalChangesToManagedContext(siteData, doSave: doSave)
    }

    func getRelatedHormones(_ siteId: UUID) -> [HormoneStruct] {
        if let site = entities.getManagedSite(by: siteId) {
            return getRelatedHormones(site)
        }
        return []
    }

    private func pushLocalChangesToManagedContext(_ siteData: [SiteStruct], doSave: Bool) {
        entities.pushSiteDataToManagedContext(siteData, doSave: doSave)
    }

    private func getRelatedHormones(_ site: MOSite) -> [HormoneStruct] {
        var hormones: [HormoneStruct] = []
        guard let relatedHormones = site.hormoneRelationship else {
            return hormones
        }
        return constructHormoneData(relatedHormones, site, &hormones)
    }
    
    private func constructHormoneData(
        _ hormoneRelationship: NSSet, _ site: MOSite, _ hormoneList: inout [HormoneStruct]
    ) -> [HormoneStruct] {

        for ele in hormoneRelationship {
            if let hormone = ele as? MOHormone, let hormoneData = createHormoneData(hormone, site) {
                hormoneList.append(hormoneData)
            }
        }
        return hormoneList
    }
    
    private func createHormoneData(_ hormone: MOHormone, _ site: MOSite) -> HormoneStruct? {
        guard let hormoneId = hormone.id else {
            return nil
        }
        return HormoneStruct(
            hormoneId,
            site.id,
            site.name,
            hormone.date as Date?,
            hormone.siteNameBackUp
        )
    }
}
