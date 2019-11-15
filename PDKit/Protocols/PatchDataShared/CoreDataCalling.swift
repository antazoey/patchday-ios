//
//  PatchDataCalling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDCoreDataDelegate: Saving {
    func createPill() -> Swallowable?
    func createPill(named name: String) -> Swallowable?
    func createHormoneList(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal]
    func createHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?
    func createSiteList(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Bodily]
    func createSite(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Bodily?
    func createPillList() -> [Swallowable]
    func nuke()
}
