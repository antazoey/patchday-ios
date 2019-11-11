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
    
    /// Swaps the index of two sites.
    func swapSites(_ sourceIndex: Index, with destinationIndex: Index)

    // MARK: - Stateful
    
    /// Marks the current quantity in the state for tracking purposes.
    func stampQuantity()
    
    /// Tracks that a hormone has changed at the given index.
    func stateChanged(forHormoneAtIndex index: Index) -> Bool
}
