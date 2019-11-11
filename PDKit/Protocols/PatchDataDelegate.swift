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
    
    /// Resets all data to default values.
    func nuke()

    // MARK: - Stateful
    
    /// Marks the current quantity in the state for tracking purposes.
    func stampQuantity()
    
    /// Tracks that a hormone has changed at the given index.
    func stateChanged(forHormoneAtIndex index: Index) -> Bool
}
