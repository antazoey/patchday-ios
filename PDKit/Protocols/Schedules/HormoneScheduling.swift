//
//  HormoneScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol HormoneScheduling: Schedule, Sorting, Resetting {
    
    /// All the hormones.
    var all: [Hormonal] { get }
    
    /// Whether you have any hormones in the schedule.
    var isEmpty: Bool { get }
    
    /// The next hormone to expire.
    var next: Hormonal? { get }
    
    /// The number of hormones that are past their expiration dates.
    var totalExpired: Int { get }
    
    /// Inserts a new hormone into the schedule.
    @discardableResult
    func insertNew() -> Hormonal?
    
    /// Resets all hormone properties to their default values.
    @discardableResult
    func reset(completion: (() -> ())?) -> Int

    /// Persists all the changes to the hormones.
    func saveAll()
    
    /// Deletes a hormone from the schedule.
    func delete(after i: Index)
    
    /// Deletes all the hormones in the schedule.
    func deleteAll()
    
    /// Returns the hormone at the given index.
    func at(_ index: Index) -> Hormonal?
    
    /// Returns the hormone for the given ID.
    func get(by id: UUID) -> Hormonal?
    
    /// Sets the date and site for the hormone with the given ID.
    func set(by id: UUID, date: Date, site: Bodily, doSave: Bool)
    
    /// Sets the date and site for the hormone at given index.
    func set(at index: Index, date: Date, site: Bodily, doSave: Bool)
    
    /// Sets the site of the hormone with the given ID.
    func setSite(by id: UUID, with site: Bodily, doSave: Bool)
    
    /// Sets the site for the hormone at the given index.
    func setSite(at index: Index, with site: Bodily, doSave: Bool)
    
    /// Sets the date of the hormone with the given ID.
    func setDate(by id: UUID, with date: Date, doSave: Bool)
    
    /// Sets the date for the hormone at the given index.
    func setDate(at index: Index, with date: Date, doSave: Bool)
    
    /// Gets the first index of the given hormone.
    func indexOf(_ hormone: Hormonal) -> Index?
    
    /// Fills in hormones from the current quantity to the given one.
    func fillIn(to stopCount: Int)
    
    /// Share hormone data with other applications that have permission, such as PatchDayToday.
    func shareData()
}
