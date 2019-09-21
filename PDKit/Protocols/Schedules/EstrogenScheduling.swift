//
//  EstrogenScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol EstrogenScheduling: PDSchedule, PDSimpleSorting {
    var get: [Hormonal] { get }
    var isEmpty: Bool { get }
    var next: Hormonal? { get }
    func insert(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?
    func reset(completion: (() -> ())?, deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD)
    func reset(from start: Index)
    func new(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD)
    func delete(after i: Index)
    func getEstrogen(at index: Index) -> Hormonal?
    func getEstrogen(for id: UUID) -> Hormonal?
    func setSite(at index: Index, with site: Bodily)
    func setDate(at index: Index, with date: Date)
    func setEstrogenDateAndSite(for id: UUID, date: Date, site: Bodily)
    func setBackUpSiteName(of index: Index, with name: String)
    func indexOf(_ estrogen: Hormonal) -> Index?
    func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool
    func totalDue(_ interval: ExpirationIntervalUD) -> Int
}
