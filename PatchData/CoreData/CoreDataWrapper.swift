//
//  PDPatchDataSecretary.swift
//  PatchData
//
//  Created by Juliya Smith on 9/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class CoreDataWrapper: CoreDataCalling {

    public func save() {
        PDCoreData.save()
    }
    
    public func createPill() -> Swallowable? {
        PDCoreData.createPill(name: SiteStrings.newSite)
    }

    public func createPill(named name: String) -> Swallowable? {
        PDCoreData.createPill(name: name)
    }

    public func createHormoneList(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        PDCoreData.createHormones(expirationInterval: expiration, deliveryMethod: deliveryMethod)
    }

    public func createHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        PDCoreData.createHormone(expirationInterval: expiration, deliveryMethod: deliveryMethod)
    }

    public func createSiteList(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Bodily] {
        PDCoreData.createSites(expirationIntervalUD: expiration, deliveryMethod: deliveryMethod)
    }

    public func createSite(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Bodily? {
        PDCoreData.createSite(expirationIntervalUD: expiration, deliveryMethod: deliveryMethod)
    }

    public func createPillList() -> [Swallowable] {
        PDCoreData.createPills()
    }

    public func nuke() {
        PDCoreData.nuke()
    }
}
