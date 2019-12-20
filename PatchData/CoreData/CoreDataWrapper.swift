//
//  CoreDataWrapper.swift
//  PatchData
//
//  Created by Juliya Smith on 9/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataWrapper: PDCoreDataDelegate {

    public func save() {
        PDCoreData.save()
    }
    
    public func createNewPill() -> Swallowable? {
        PDCoreData.createPill(name: SiteStrings.newSite)
    }

    public func createNewPill(named name: String) -> Swallowable? {
        PDCoreData.createPill(name: name)
    }

    public func loadHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        PDCoreData.createHormones(expirationInterval: expiration, deliveryMethod: deliveryMethod)
    }

    public func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        PDCoreData.createHormone(expirationInterval: expiration, deliveryMethod: deliveryMethod)
    }

    public func loadSites(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Bodily] {
        PDCoreData.createSites(expirationIntervalUD: expiration, deliveryMethod: deliveryMethod)
    }

    public func createNewSite(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Bodily? {
        PDCoreData.createSite(expirationIntervalUD: expiration, deliveryMethod: deliveryMethod)
    }

    public func createPills() -> [Swallowable] {
        PDCoreData.createPills()
    }

    public func nuke() {
        PDCoreData.nuke()
    }
}
