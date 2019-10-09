//
//  SiteSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PDSites: NSObject, HormoneSiteScheduling {
    
    override public var description: String {
        return "Schedule for maintaining sites for hormone patches or injections."
    }
    
    private var sites: [Bodily]
    var next: Index = 0
    let siteIndexRebounder: PDIndexRebounce
    
    init(deliveryMethod: DeliveryMethod,
         globalExpirationInterval: ExpirationIntervalUD,
         siteIndexRebounder: PDIndexRebounce) {
        self.sites = PatchData.createSites(
            expirationIntervalUD: globalExpirationInterval,
            deliveryMethod: deliveryMethod
        )
        self.siteIndexRebounder = siteIndexRebounder
        super.init()
        if sites.count == 0 {
            new(
                deliveryMethod: deliveryMethod,
                globalExpirationInterval: globalExpirationInterval
            )
        }
        sort()
    }
    
    public var count: Int { return sites.count }
    
    public var all: [Bodily] { return sites }
    
    /// The next site in the site schedule as a suggestion of where to relocate.
    public var suggested: Bodily? {
        if let i = nextIndex { return sites[i] }
        return nil
    }
    
    // An array of a siteNames for each site in the schedule.
    public var names: [SiteName] {
        return sites.map({ (site: Bodily) -> SiteName in return site.name })
    }
    
    /// An array of image Ids for each site
    public var imageIds: [String] {
        return sites.map({ (site: Bodily) -> String in return site.imageIdentifier })
    }
    
    /// The next site for scheduling in the site schedule.
    public var nextIndex: Index? {
        if next < 0 {
            next = siteIndexRebounder.rebound(upon: 0, lessThan: sites.count)
        }
        if sites.count <= 0 {
            return nil
        }
        for i in 0..<sites.count {
            // Return site that has no estros
            if sites[i].hormones.count == 0 {
                next = siteIndexRebounder.rebound(upon: i, lessThan: sites.count)
            }
        }
        return next
    }
    
    /// Appends the the new site to the sites and returns it.
    public func insert(deliveryMethod: DeliveryMethod,
                       globalExpirationInterval: ExpirationIntervalUD,
                       completion: (() -> ())? = nil) -> Bodily? {
        let i = globalExpirationInterval
        if let site = PDSite.new(deliveryMethod: deliveryMethod, globalExpirationInterval: i) {
            return site
        }
        return nil
    }

    /// Resets the site array a default list of sites.
    public func reset(deliveryMethod: DeliveryMethod,
                      globalExpirationInterval: ExpirationIntervalUD) {
        if isDefault(deliveryMethod: deliveryMethod) {
            return
        }
        let resetNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
        let oldCount = sites.count
        let newcount = resetNames.count
        for i in 0..<newcount {
            if i < oldCount {
                sites[i].order = i
                sites[i].name = resetNames[i]
                sites[i].imageIdentifier = resetNames[i]
            } else if var site = insert(deliveryMethod: deliveryMethod,
                                        globalExpirationInterval: globalExpirationInterval) {
                site.name = resetNames[i]
                site.imageIdentifier = resetNames[i]
            }
        }
        if oldCount > resetNames.count {
            for i in resetNames.count..<oldCount {
                sites[i].reset()
            }
        }
        sort()
        PatchData.save()
    }
    
    /// Deletes the site at the given index.
    public func delete(at index: Index) {
        switch (index) {
        case 0..<sites.count :
            sites[index].pushBackupSiteNameToEstrogens()
            sites[index].delete()
            sites[index].reset()
            if (index + 1) < (sites.count - 1) {
                for i in (index+1)..<sites.count {
                    sites[i].order -= 1
                }
            }
            sort()
            PatchData.save()
        default : return
        }
    }
    
    /// Generates a generic list of sites when there are none in store.
    public func new(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD) {
        var sites: [Bodily] = []
        let names = PDSiteStrings.getSiteNames(for: deliveryMethod)
        for i in 0..<names.count {
            if var site = insert(deliveryMethod: deliveryMethod, globalExpirationInterval: globalExpirationInterval) {
                site.name = names[i]
                site.imageIdentifier = names[i]
                sites.append(site)
            }
        }
        self.sites = sites
        sort()
        PatchData.save()
    }
    
    public func sort() {
        if var sites = self.sites as? [PDSite] {
            sites.sort()
        }
    }

    // MARK: - Other Public

    /// Returns the site at the given index.
    public func at(_ index: Index) -> Bodily? {
        if index >= 0 && index < sites.count {
            return sites[index]
        }
        return nil
    }
    
    /// Returns the site for the given name.
    public func get(for name: String) -> Bodily? {
        if let i = names.firstIndex(of: name) {
            return sites[i]
        }
        return nil
    }
    
    /// Sets a the siteName for the site at the given index.
    public func rename(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].name = name
            PatchData.save()
        }
    }
    
    /// Swaps the indices of two sites by setting the order.
    public func reorder(at index: Index, to newOrder: Int) {
        let newIndex = Index(newOrder)
        if index >= 0 && index < sites.count && newIndex < sites.count && newIndex >= 0 {
            // Make sure index is correct both before and after swap
            sort()
            sites[index].order = newOrder
            sites[newIndex].order = index
            sort()
            PatchData.save()
        }
    }
    
    /// Sets the site image Id for the site at the given index.
    public func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod) {
        var site_set: [String]
        site_set = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if site_set.contains(newId), index >= 0 && index < sites.count {
            sites[index].imageIdentifier = newId
        } else {
            sites[index].imageIdentifier = "custom"
        }
        PatchData.save()
    }

    /// Returns the set of sites on record union with the set of default sites
    public func unionize(deliveryMethod: DeliveryMethod) -> Set<SiteName> {
        let defaults = Set<String>(PDSiteStrings.getSiteNames(for: deliveryMethod))
        return Set(names).union(defaults)
    }
    
    /// Returns if the sites in the site schedule are the same as the default sites.
    public func isDefault(deliveryMethod: DeliveryMethod) -> Bool {
        let defaultSites = PDSiteStrings.getSiteNames(for: deliveryMethod)
        for i in 0..<sites.count {
            if !defaultSites.contains(sites[i].name) {
                return false
            }
        }
        return true
    }
}
