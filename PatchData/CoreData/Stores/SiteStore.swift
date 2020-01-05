//
//  SiteStore.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SiteStore: EntityStore {

    func getStoredSites(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [Bodily] {
        var sites: [Bodily] = []
        let siteDataEntries = entities.getStoredSiteData(
            expiration: expiration, method: method
        )
        for siteData in siteDataEntries {
            let site = Site(siteData: siteData, expirationInterval: expiration, deliveryMethod: method)
            sites.append(site)
        }
        return sites
    }

    func createNewSite(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool) -> Bodily? {
        if let newSiteDataFromStore = entities.createNewSite(expiration: expiration, method: method, doSave: doSave) {
            return Site(siteData: newSiteDataFromStore, expirationInterval: expiration, deliveryMethod: method)
        }
        return nil
    }

    func delete(_ site: Bodily) {
        entities.deleteSiteData([CoreDataEntityAdapter.convertToSiteStruct(site)])
    }

    func pushLocalChangesToBeSaved(_ sites: [Bodily]) {
        if sites.count == 0 {
            return
        }
        let siteData = sites.map { s in CoreDataEntityAdapter.convertToSiteStruct(s) }
        self.pushLocalChangesToBeSaved(siteData)
    }

    func pushLocalChangesToBeSaved(_ site: Bodily) {
        self.pushLocalChangesToBeSaved([CoreDataEntityAdapter.convertToSiteStruct(site)])
    }

    private func pushLocalChangesToBeSaved(_ siteData: [SiteStruct]) {
        entities.pushSiteData(siteData)
    }
}