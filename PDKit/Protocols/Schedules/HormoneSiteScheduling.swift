//
//  PDEstrogenSiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneSiteScheduling: Schedule, Sorting, Deleting, Resetting {
    
    /// All the sites.
    var all: [Bodily] { get }
    
    /// The currently next suggested site for applying a hormone.
    var suggested: Bodily? { get }
    
    /// The index of suggested site or -1 if there are no sites.
    var nextIndex: Index { get }
    
    /// The list of all sites containing hormones.
    var occupiedSites: [Bodily] { get }
    
    /// The indices of all the sites containing hormones.
    var occupiedSitesIndices: [Index] { get }
    
    /// All names.
    var names: [SiteName] { get }
    
    /// All image IDs.
    var imageIds: [String] { get }
    
    /// The set of current site names union with the default ones.
    var unionWithDefaults: [SiteName] { get }
    
    /// If the sites use the default scheme for the given delivery method.
    var isDefault: Bool { get }
    
    /// Inserts a new site into the schedule.
    func insertNew() -> Bodily?

    /// Inserts a new site into the schedule.
    func insertNew(completion: (() -> ())?) -> Bodily?
    
    /// The site at the given index.
    func at(_ index: Index) -> Bodily?
    
    /// Gets the site for the given name.
    func get(for name: String) -> Bodily?
    
    /// Changes the name of a site.
    func rename(at index: Index, to name: String)
    
    /// Changes the order of the site at the given index and adjusts the order of the other sites.
    func reorder(at index: Index, to newOrder: Int)
    
    /// Sets  the image ID of the site at the given index.
    func setImageId(at index: Index, to newId: String)
    
    /// Returns the first index of the given site.
    func indexOf(_ site: Bodily) -> Index?
}
