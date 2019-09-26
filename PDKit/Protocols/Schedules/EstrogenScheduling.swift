//
//  EstrogenScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol EstrogenScheduling: PDSchedule, PDSimpleSorting {
    var all: [Hormonal] { get }
    var isEmpty: Bool { get }
    var next: Hormonal? { get }
    func insert(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?
    func reset(completion: (() -> ())?, deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD)
    func reset(from start: Index)
    func new(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD)
    func delete(after i: Index)
    func at(_ index: Index) -> Hormonal?
    func get(for id: UUID) -> Hormonal?
    func set(for id: UUID, date: Date, site: Bodily)
    func setSite(at index: Index, with site: Bodily)
    func setDate(at index: Index, with date: Date)
    func setBackUpSiteName(of index: Index, with name: String)
    func indexOf(_ estrogen: Hormonal) -> Index?
    func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool
    func totalExpired(_ interval: ExpirationIntervalUD) -> Int
}
