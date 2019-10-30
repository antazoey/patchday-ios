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
    
    /// Read or write UserDefaults
    var defaults: PDDefaultManaging { get }
    
    /// Schedule and manage PDHormones.
    var hormones: HormoneScheduling { get }
    
    /// Schedule and manage PDSites.
    var sites: HormoneSiteScheduling { get }
    
    /// Schedule and manage PDPills
    var pills: PDPillScheduling { get }
    
    /// Read the state of recent mutations.
    var state: PDStateManaging { get }
    
    /// The expired hormones count plus the due pills count.
    var totalAlerts: Int { get }
    
    /// Names of sites that contain hormones.
    var occupiedSites: Set<SiteName> { get }
    
    /// Resets all data to default values.
    func nuke()
    
    // MARK: - Defaults
    
    /// Current delivery method set in user defaults.
    var deliveryMethod: DeliveryMethod { get }

    /// Current hormone quanity set in user defaults.
    var quantity: Int { get }
    
    /// Current expiration interval set in user defaults.
    var expirationInterval: ExpirationInterval { get }
    
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

    /// A convenient way to insert a new site.
    func insertNewSite(name: SiteName, completion: (() -> ())?)
    
    /// A convenient way to insert a site with the given name.
    func insertNewSite(name: SiteName)
    
    /// A convenient way to insert a new site.
    func insertNewSite()
    
    /// Swap the index of two sites.
    func swapSites(_ sourceIndex: Index, with destinationIndex: Index)
    
    /// A convenient way to reset sites to default.
    @discardableResult func resetSitesToDefault() -> Int

    // MARK: - Stateful
    
    /// Mark the current quantity in the state in preparation of potential change.
    func stampQuantity()
    
    /// Track that a hormone changed at the given index.
    func stateChanged(forHormoneAtIndex index: Index) -> Bool

    // MARK: - Hormones

    /// How many hormones are ready for redose.
    var totalHormonesExpired: Int { get }

    /// Set hormone site with stateful / data meter side effects.
    func setHormoneSite(at index: Index, with site: Bodily)

    /// Set hormone date with stateful / data meter side effects.
    func setHormoneDate(at index: Index, with date: Date)

    /// Set hormone date and site with stateful / data meter side effects.
    func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily)
    
    /// Set hormone at given index date and site with stateful / data meter side effects.
    func setHormoneDateAndSite(at index: Index, date: Date, site: Bodily)

    // MARK: - Pills
    
    /// Swallow the pill with stateful / data meter side effects.
    func swallow(_ pill: Swallowable)
    
    /// Set pill attributes with stateful / data meter side effects.
    func setPill(_ pill: Swallowable, with attributes: PillAttributes)
}
