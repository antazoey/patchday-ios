//
//  PDScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PatchDataDelegate {
    
    /// If this is the first initialization.
    var isFresh: Bool { get }
    
    /// The UserDefaults manager.
    var defaults: PDDefaultManaging { get }
    
    /// PDHormones schedule.
    var hormones: HormoneScheduling { get }
    
    /// The PDSites schedule.
    var sites: HormoneSiteScheduling { get }
    
    /// The PDPills schedule.
    var pills: PDPillScheduling { get }
    
    /// A state manager for recent mutations.
    var state: PDStateManaging { get }
    
    /// The expired hormones count plus the due pills count.
    var totalAlerts: Int { get }
    
    /// The names of sites that contain hormones.
    var occupiedSites: Set<SiteName> { get }
    
    /// Resets all data to default values.
    func nuke()
    
    // MARK: - Defaults
    
    /// The current delivery method set in user defaults. The method by which you take hormones.
    var deliveryMethod: DeliveryMethod { get }
    
    /// Sets the delivery method in UserDefaults with stateful side effects.
    func setDeliveryMethod(to newMethod: DeliveryMethod)
    
    /// Sets the quantity in UserDefaults with stateful side effects.
    func setQuantity(to newQuantity: Int)
    
    /// Sets the expiration interval in UserDefaults with stateful side effects.
    func setExpirationInterval(to newInterval: String)
    
    /// Sets the theme in UserDefaults with stateful side effects.
    func setTheme(to newTheme: String)
    
    /// Sets the site index in UserDefaults with stateful side effects and optionally returns the new index.
    @discardableResult func setSiteIndex(to newIndex: Index) -> Index

    // MARK: - Sites

    /// Conveniently inserts a new site.
    func insertNewSite(name: SiteName, completion: (() -> ())?)
    
    /// Conveniently inserts a site with the given name.
    func insertNewSite(name: SiteName)
    
    /// Conveniently inserts a new site.
    func insertNewSite()
    
    /// Swaps the index of two sites.
    func swapSites(_ sourceIndex: Index, with destinationIndex: Index)
    
    /// Conveniently resets sites to their default.
    @discardableResult func resetSitesToDefault() -> Int

    // MARK: - Stateful
    
    /// Marks the current quantity in the state for tracking purposes.
    func stampQuantity()
    
    /// Tracks that a hormone has changed at the given index.
    func stateChanged(forHormoneAtIndex index: Index) -> Bool

    // MARK: - Hormones

    /// The amount of hormones that are past their expiration dates.
    var totalHormonesExpired: Int { get }

    /// Sets the site for the hormone at the given index. Includes stateful and data-meter side-effects.
    func setHormoneSite(at index: Index, with site: Bodily)

    /// Sets the date for the hormone at the given index. Includes stateful and data-meter side-effects.
    func setHormoneDate(at index: Index, with date: Date)

    /// Sets the date and site for the hormone with the given id. Includes stateful and data-meter side-effects.
    func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily)
    
    /// Sets the date and site for the hormone at given index. Includes stateful and data-meter side-effects.
    func setHormoneDateAndSite(at index: Index, date: Date, site: Bodily)

    // MARK: - Pills
    
    /// Swallows the pill. Includes stateful and data-meter side-effects.
    func swallow(_ pill: Swallowable)
    
    /// Sets pill attributes. Includes stateful and data-meter side-effects.
    func setPill(_ pill: Swallowable, with attributes: PillAttributes)
    
    /// Conveniently inserts a new pill.
    @discardableResult func insetNewPill() -> Swallowable?
    
    /// Delete the pill. Includes data meter side effects.
    func deletePill(at index: Index)
}
