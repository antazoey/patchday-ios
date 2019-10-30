//
//  PDEstrogenSiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneSiteScheduling: PDSchedule, PDSorting, PDDeleting, PDResetting {
    
    /// All the sites.
    var all: [Bodily] { get }
    
    /// The currently next suggested for hormone use.
    var suggested: Bodily? { get }
    
    /// The index of suggested site.
    var nextIndex: Index? { get }
    
    /// All names.
    var names: [SiteName] { get }
    
    /// All image IDs.
    var imageIds: [String] { get }

    /// Inset a new site into the schedule.
    func insertNew(
        deliveryMethod: DeliveryMethod,
        globalExpirationInterval: ExpirationIntervalUD,
        completion: (() -> ())?
    ) -> Bodily?
    
    /// Get the site at the given index.
    func at(_ index: Index) -> Bodily?
    
    /// Get the site for the given name.
    func get(for name: String) -> Bodily?
    
    /// Change the name of a site.
    func rename(at index: Index, to name: String)
    
    /// Change the order of the site.
    func reorder(at index: Index, to newOrder: Int)
    
    /// Set  the image ID of the site at the given index.
    func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod)
    
    /// Get the set of current site names with the default ones.
    func unionWithDefaults(deliveryMethod: DeliveryMethod) -> Set<SiteName>
    
    /// If uses the default site set for the given delivery method.
    func isDefault(deliveryMethod: DeliveryMethod) -> Bool
    
    /// Swap two sites from given indices.
    func swap(_ sourceIndex: Index, with destinationIndex: Index)
}
