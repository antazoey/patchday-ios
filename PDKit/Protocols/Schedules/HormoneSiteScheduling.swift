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
    
    /// The currently next suggested site for applying a hormone.
    var suggested: Bodily? { get }
    
    /// The index of suggested site.
    var nextIndex: Index? { get }
    
    /// All names.
    var names: [SiteName] { get }
    
    /// All image IDs.
    var imageIds: [String] { get }

    /// Insets a new site into the schedule.
    func insertNew(
        deliveryMethod: DeliveryMethod,
        globalExpirationInterval: ExpirationIntervalUD,
        completion: (() -> ())?
    ) -> Bodily?
    
    /// The site at the given index.
    func at(_ index: Index) -> Bodily?
    
    /// Gets the site for the given name.
    func get(for name: String) -> Bodily?
    
    /// Changes the name of a site.
    func rename(at index: Index, to name: String)
    
    /// Changes the order of the site at the given index and adjusts the order of the other sites.
    func reorder(at index: Index, to newOrder: Int)
    
    /// Sets  the image ID of the site at the given index.
    func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod)
    
    /// Gets the set of current site names union with the default ones.
    func unionWithDefaults(deliveryMethod: DeliveryMethod) -> Set<SiteName>
    
    /// Checks if the sites use the default scheme for the given delivery method.
    func isDefault(deliveryMethod: DeliveryMethod) -> Bool
}
