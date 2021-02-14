//
//  HormoneScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.

import Foundation

public protocol HormoneScheduling: Schedule, Resetting {

    /// All the hormones.
    var all: [Hormonal] { get }

    /// Whether you have any hormones in the schedule.
    var isEmpty: Bool { get }

    /// The next hormone to expire.
    var next: Hormonal? { get }

    /// The number of hormones that are past their expiration dates.
    var totalExpired: Int { get }

    /// Force reload of from backend.
    func reloadContext()

    /// Inserts a new hormone into the schedule.
    @discardableResult
    func insertNew() -> Hormonal?

    /// Resets all hormone properties to their default values.
    @discardableResult
    func reset(completion: (() -> Void)?) -> Int

    /// Persists all the changes to the hormones.
    func saveAll()

    /// Deletes a hormone from the schedule.
    func delete(after i: Index)

    /// Deletes all the hormones in the schedule.
    func deleteAll()

    /// Returns the hormone at the given index.
    subscript(index: Index) -> Hormonal? { get }

    /// Returns the hormone for the given ID.
    subscript(id: UUID) -> Hormonal? { get }

    /// Sets the date and site for the hormone with the given ID.
    func set(by id: UUID, date: Date, site: Bodily)

    /// Sets the date and site for the hormone at given index.
    func set(at index: Index, date: Date, site: Bodily)

    /// Sets the site of the hormone with the given ID.
    func setSite(by id: UUID, with site: Bodily)

    /// Sets the site for the hormone at the given index.
    func setSite(at index: Index, with site: Bodily)

    /// Sets the site name back-up (a non-managed site) of the hormone with the given ID.
    func setSiteName(by id: UUID, with siteName: SiteName)

    /// Sets the date of the hormone with the given ID.
    func setDate(by id: UUID, with date: Date)

    /// Sets the date for the hormone at the given index.
    func setDate(at index: Index, with date: Date)

    /// Gets the first index of the given hormone.
    func indexOf(_ hormone: Hormonal) -> Index?

    /// Fills in hormones from the current quantity to the given one.
    func fillIn(to stopCount: Int)

    /// Share hormone data with other applications that have permission, such as PatchDayToday.
    func shareData()
}
