//
//  PillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.

import Foundation

public protocol PillScheduling: Schedule, Deleting {

    /// All the pills.
    var all: [Swallowable] { get }

    /// The next pill due.
    var nextDue: Swallowable? { get }

    /// The due count.
    var totalDue: Int { get }

    /// Force reloads data from storage.
    func reloadContext()

    /// Insert a new pill into the schedule.
    @discardableResult
    func insertNew(onSuccess: (() -> Void)?) -> Swallowable?

    /// Get the pill at the given index.
    subscript(index: Index) -> Swallowable? { get }

    /// Get the pill for the given ID.
    subscript(id: UUID) -> Swallowable? { get }

    /// Set the pill at the given index with the given attributes.
    func set(at index: Index, with attributes: PillAttributes)

    /// Set the pill for the givne ID with the given attributes.
    func set(by id: UUID, with attributes: PillAttributes)

    /// Reset all pill attributes to their default.
    func reset()

    /// Swallow the pill.
    func swallow(_ id: UUID, onSuccess: (() -> Void)?)

    /// Swallow the next pill due.
    func swallow(onSuccess: (() -> Void)?)

    /// Undo swallowing a pill. Must provide the previous last taken date or the date to set `lastTaken` to.
    func unswallow(_ id: UUID, lastTaken: Date?, onSuccess: (() -> Void)?)

    /// Get the first index of the given pill.
    func indexOf(_ pill: Swallowable) -> Index?

    /// Share pill data with other applications that have permission, such as PatchDayToday.
    func shareData()

    /// Awaken the properties that are relevant to the current date and time.
    func awaken()
}
