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

    /// Get the pill at the given index.
    func at(_ index: Index) -> Swallowable?
    
    /// Get the pill for the given ID.
    func get(for id: UUID) -> Swallowable?
    
    /// Set the pill at the given index with the given attributes.
    func set(at index: Index, with attributes: PillAttributes)
    
    /// Set the pill with the given attributes.
    func set(for pill: Swallowable, with attributes: PillAttributes)
    
    /// Reset to default pills from first initialization.
    func reset()
    
    /// Swallow the pill at the given index.
    func swallow(at index: Index, completion: (() -> ())?)
    
    /// Swallow the pill.
    func swallow(_ pill: Swallowable, completion: (() -> ())?)
    
    /// Swallow the next pill due.
    func swallow(completion: (() -> ())?)
}
