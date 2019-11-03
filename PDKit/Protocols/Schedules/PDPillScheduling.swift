//
//  PDPillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDPillScheduling: PDSchedule, PDDeleting {
    
    /// All the pills.
    var all: [Swallowable] { get }
    
    /// The next pill due.
    var nextDue: Swallowable? { get }
    
    /// The due count.
    var totalDue: Int { get }
    
    /// Insert a new pill into the schedule.
    func insertNew(completion: (() -> ())?) -> Swallowable?

    /// The pill at the given index.
    func at(_ index: Index) -> Swallowable?
    
    /// Gets the pill for the given ID.
    func get(for id: UUID) -> Swallowable?
    
    /// Sets the pill at the given index with the given attributes.
    func set(at index: Index, with attributes: PillAttributes)
    
    /// Sets the pill with the given attributes.
    func set(for pill: Swallowable, with attributes: PillAttributes)
    
    /// Resets all pill attributes to their default.
    func reset()
    
    /// Swallows the pill at the given index.
    func swallow(at index: Index, completion: (() -> ())?)
    
    /// Swallows the pill.
    func swallow(_ pill: Swallowable, completion: (() -> ())?)
    
    /// Swallows the next pill due.
    func swallow(completion: (() -> ())?)
    
    /// Gets the index of the given pill.
    func indexOf(_ pill: Swallowable) -> Index?
}
