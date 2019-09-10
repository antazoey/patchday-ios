//
//  PDEstrogenSiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol EstrogenSiteScheduling {
    var sites: [Bodily] { get }
    func insert(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD, completion: (() -> ())?) -> Bodily?
    func reset(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD, completion: (() -> ())?)
    func delete(at index: Index)
    func new(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD)
    func sort()
    func getSite(at index: Index) -> Bodily?
    func getSite(for name: String) -> Bodily?
    func setName(at index: Index, to name: String)
    func setOrder(at index: Index, to newOrder: Int)
    func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod)
    func nextIndex(changeIndex: (Int) -> ()) -> Index?
    func suggest(changeIndex: (Int) -> ()) -> Bodily?
    func getNames() -> [SiteName]
    func getImageIds() -> [String]
    func unionize(deliveryMethod: DeliveryMethod) -> Set<SiteName>
    func isDefault(deliveryMethod: DeliveryMethod) -> Bool
}
