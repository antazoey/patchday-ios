//
//  SiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.

import Foundation

public protocol SiteScheduling: Schedule, Sorting, Deleting, Resetting {

    /// All the sites.
    var all: [Bodily] { get }

    /// The currently next suggested site for applying a hormone.
    var suggested: Bodily? { get }

    /// The index of suggested site or -1 if there are no sites.
    var nextIndex: Index { get }

    /// All names (one per site slot, so duplicates appear when several slots
    /// share a name).
    var names: [SiteName] { get }

    /// Distinct site names in schedule order. Use this for site pickers so the
    /// same name isn't offered repeatedly when several physical site slots
    /// share it.
    var uniqueNames: [SiteName] { get }

    /// If the sites use the default scheme for the given delivery method.
    var isDefault: Bool { get }

    /// Force reload context from database.
    func reloadContext()

    /// Insert a new site into the schedule.
    @discardableResult
    func insertNew(name: String, onSuccess: ((Bodily) -> Void)?) -> Bodily?

    /// Duplicate the site at `index` (same name and image) as a new schedule
    /// slot. Used to add another physical slot for a site that shares a name,
    /// so multiple hormones can rotate across same-named locations.
    @discardableResult
    func clone(at index: Index) -> Bodily?

    /// Replace the schedule's sites with the given ordered names, reusing
    /// existing slots and creating/deleting slots so the schedule matches.
    /// Repeated names become repeated slots. Used to apply a preset scheme.
    func setSites(to names: [SiteName])

    /// Resolve a (possibly duplicated) site name to the concrete site slot that
    /// should receive a hormone. Prefers the slot the hormone already occupies
    /// when it carries that name (so re-saving is idempotent), otherwise the
    /// first unused slot of that name, otherwise the slot whose hormone is
    /// oldest. Returns nil when no slot carries the name.
    /// - Parameter currentSiteId: the site the hormone is currently on, if any.
    func site(forName name: SiteName, preferring currentSiteId: UUID?) -> Bodily?

    /// Get the site at the given index.
    subscript(index: Index) -> Bodily? { get }

    /// Get the site for the given ID.
    subscript(id: UUID) -> Bodily? { get }

    /// Change the name of a site.
    func rename(at index: Index, to name: SiteName)

    /// Change the order of the site at the given index and adjusts the order of the other sites.
    func reorder(at index: Index, to newOrder: Int)

    /// Set the image ID of the site at the given index.
    func setImageId(at index: Index, to newId: String)

    /// Get the first first index of the given site.
    func indexOf(_ site: Bodily) -> Index?
}
