//
//  PDEstrogenSiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol EstrogenSiteScheduling: PDSchedule, PDSimpleSorting {
    var get: [Bodily] { get }
    var suggestedSite: Bodily? { get }
    var names: [SiteName] { get }
    var imageIds: [String] { get }
    var nextIndex: Index? { get }
    func insert(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD, completion: (() -> ())?) -> Bodily?
    func reset(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD)
    func delete(at index: Index)
    func new(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD)
    func getSite(at index: Index) -> Bodily?
    func getSite(for name: String) -> Bodily?
    func setName(at index: Index, to name: String)
    func setOrder(at index: Index, to newOrder: Int)
    func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod)
    func unionize(deliveryMethod: DeliveryMethod) -> Set<SiteName>
    func isDefault(deliveryMethod: DeliveryMethod) -> Bool
}
