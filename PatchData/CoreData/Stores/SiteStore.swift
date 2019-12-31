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

    func getStoredSites(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Bodily] {
        var sites: [Bodily] = []
        for siteData in entities.getStoredSiteData(
            expirationInterval: expirationInterval, deliveryMethod: deliveryMethod
        ) {
            let site = Site(siteData: siteData, expirationInterval: expirationInterval, deliveryMethod: deliveryMethod)
            sites.append(site)
        }
        return sites
    }

    func createNewSite(expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Bodily? {
        if let newSiteDataFromStore = entities.createNewSite(
            expirationInterval: expirationInterval, deliveryMethod: deliveryMethod
        ) {
            return Site(
                siteData: newSiteDataFromStore, expirationInterval: expirationInterval, deliveryMethod: deliveryMethod
            )
        }
        return nil
    }

    func save(_ sites: [Bodily]) {
        let siteData = sites.map { s in CoreDataEntityAdapter.convertToSiteStruct(s) }
        self.save(siteData)
    }

    func save(_ site: Bodily) {
        self.save([CoreDataEntityAdapter.convertToSiteStruct(site)])
    }

    private func save(_ siteData: [SiteStruct]) {
        entities.pushSiteData(siteData)
        stack.save()
    }
}