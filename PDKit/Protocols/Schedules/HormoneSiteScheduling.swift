//
//  PDEstrogenSiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneSiteScheduling: PDSchedule, PDSimpleSorting {
    var all: [Bodily] { get }
    var suggested: Bodily? { get }
    var names: [SiteName] { get }
    var imageIds: [String] { get }
    var nextIndex: Index? { get }
    func insert(deliveryMethod: DeliveryMethod,
                globalExpirationInterval: ExpirationIntervalUD,
                completion: (() -> ())?) -> Bodily?
    func reset(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD)
    func delete(at index: Index)
    func new(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD)
    func at(_ index: Index) -> Bodily?
    func get(for name: String) -> Bodily?
    func rename(at index: Index, to name: String)
    func reorder(at index: Index, to newOrder: Int)
    func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod)
    func unionize(deliveryMethod: DeliveryMethod) -> Set<SiteName>
    func isDefault(deliveryMethod: DeliveryMethod) -> Bool
}
