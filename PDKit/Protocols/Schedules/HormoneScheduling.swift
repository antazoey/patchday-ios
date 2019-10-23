//
//  EstrogenScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneScheduling: PDSchedule, PDSimpleSorting {
    var all: [Hormonal] { get }
    var isEmpty: Bool { get }
    var next: Hormonal? { get }
    func insertNew(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?
    func reset(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD)
    func reset(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD, completion: (() -> ())?)
    func delete(after i: Index)
    func deleteAll()
    func at(_ index: Index) -> Hormonal?
    func get(for id: UUID) -> Hormonal?
    func set(for id: UUID, date: Date, site: Bodily)
    func setSite(at index: Index, with site: Bodily)
    func setDate(at index: Index, with date: Date)
    func setBackUpSiteName(at index: Index, with name: String)
    func indexOf(_ hormone: Hormonal) -> Index?
    func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool
    func totalExpired(_ interval: ExpirationIntervalUD) -> Int
    func fillIn(newQuantity: Int,expiration: ExpirationIntervalUD,deliveryMethod: DeliveryMethod)
}
