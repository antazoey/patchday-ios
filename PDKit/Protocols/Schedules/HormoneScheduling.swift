//
//  EstrogenScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneScheduling: PDSchedule, PDSorting, PDResetting {
    
    /// All the hormones
    var all: [Hormonal] { get }
    
    /// If you did not set any hormones.
    var isEmpty: Bool { get }
    
    /// If you did not set the hormones in the given range.
    func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool
    
    /// The next to expire.
    var next: Hormonal? { get }
    
    /// Insert a new hormone into the schedule.
    @discardableResult func insertNew(
        deliveryMethod: DeliveryMethod,
        expiration: ExpirationIntervalUD
    ) -> Hormonal?
    
    /// Reset all properties to their default values.
    @discardableResult func reset(
        deliveryMethod: DeliveryMethod,
        interval: ExpirationIntervalUD,
        completion: (() -> ())?
    ) -> Int
    
    /// Delete a hormone from the schedule.
    func delete(after i: Index)
    
    /// Delete all the hormones in the schedule.
    func deleteAll()
    
    /// Get the hormone at the given index.
    func at(_ index: Index) -> Hormonal?
    
    /// Get the hormone for the given ID.
    func get(for id: UUID) -> Hormonal?
    
    /// Set properties for given ID.
    func set(for id: UUID, date: Date, site: Bodily)
    
    /// Set properties at given index.
    func set(at index: Index, date: Date, site: Bodily)
    
    /// Set site for given index.
    func setSite(at index: Index, with site: Bodily)
    
    /// Set date for given index.
    func setDate(at index: Index, with date: Date)

    /// Set back up site name at given index.
    func setBackUpSiteName(at index: Index, with name: String)
    
    /// Get the index of the given hormone.
    func indexOf(_ hormone: Hormonal) -> Index?

    /// The expired count.
    func totalExpired(_ interval: ExpirationIntervalUD) -> Int
    
    /// Fill in hormones from the current quantity to the given one.
    func fillIn(newQuantity: Int, expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod)
}
