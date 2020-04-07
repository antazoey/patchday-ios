//
//  PillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillScheduling: Schedule, Deleting {
    
    /// All the pills.
    var all: [Swallowable] { get }
    
    /// The next pill due.
    var nextDue: Swallowable? { get }
    
    /// The due count.
    var totalDue: Int { get }
    
    /// Insert a new pill into the schedule.
    @discardableResult
    func insertNew(onSuccess: (() -> ())?) -> Swallowable?
    
    /// Returns the pill at the given index.
    subscript(index: Index) -> Swallowable? { get }
    
    /// Returns the pill for the given ID.
    subscript(id: UUID) -> Swallowable? { get }
    
    /// Sets the pill at the given index with the given attributes.
    func set(at index: Index, with attributes: PillAttributes)
    
    /// Sets the pill for the givne ID with the given attributes.
    func set(by id: UUID, with attributes: PillAttributes)
    
    /// Resets all pill attributes to their default.
    func reset()

    /// Swallows the pill.
    func swallow(_ id: UUID, onSuccess: (() -> ())?)
    
    /// Swallows the next pill due.
    func swallow(onSuccess: (() -> ())?)
    
    /// Gets the first index of the given pill.
    func indexOf(_ pill: Swallowable) -> Index?
    
    /// Share pill data with other applications that have permission, such as PatchDayToday.
    func shareData()
}
