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

public class SiteSchedule: NSObject, EstrogenSiteScheduling {
    
    override public var description: String {
        return "Schedule for maintaining sites for estrogen patches or injections."
    }
    
    public var sites: [Bodily]
    var next: Index = 0
    
    init(deliveryMethod: DeliveryMethod, globalExpirationInterval: ExpirationIntervalUD) {
        sites = PatchData.createSites(expirationIntervalUD: globalExpirationInterval,
                                      deliveryMethod: deliveryMethod)
        super.init()
        if sites.count == 0 {
            new(deliveryMethod: deliveryMethod, globalExpirationInterval: globalExpirationInterval)
        }
        sort()
    }
    
    // MARK: - Overrides
    
    /// Appends the the new site to the sites and returns it.
    public func insert(deliveryMethod: DeliveryMethod,
                       globalExpirationInterval: ExpirationIntervalUD,
                       completion: (() -> ())? = nil) -> Bodily? {
        if let site = PDSite.createNew(deliveryMethod: deliveryMethod,
                                       globalExpirationInterval: globalExpirationInterval) {
            return site
        }
        return nil
    }

    /// Resets the site array a default list of sites.
    public func reset(deliveryMethod: DeliveryMethod,
                      globalExpirationInterval: ExpirationIntervalUD,
                      completion: (() -> ())? = nil) {
        if isDefault(deliveryMethod: deliveryMethod) {
            return
        }
        var resetNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
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
        if let comp = completion {
            comp()
        }
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
    
    /// Generates a generic list of MOSites when there are none in store.
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
    public func getSite(at index: Index) -> Bodily? {
        if index >= 0 && index < sites.count {
            return sites[index]
        }
        return nil
    }
    
    /// Returns the MOSite for the given name.
    public func getSite(for name: String) -> Bodily? {
        if let index = getNames().firstIndex(of: name) {
            return sites[index]
        }
        return nil
    }
    
    /// Sets a the siteName for the site at the given index.
    public func setName(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].name = name
            PatchData.save()
        }
    }
    
    /// Swaps the indices of two sites by setting the order.
    public func setOrder(at index: Index, to newOrder: Int) {
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
    
    /// Returns the next site for scheduling in the site schedule.
    public func nextIndex(changeIndex: (Int) -> ()) -> Index? {
        if next < 0 {
            changeIndex(0)
            next = 0
        }
        if sites.count <= 0 {
            return nil
        }
        for i in 0..<sites.count {
            // Return site that has no estros
            if sites[i].estrogens.count == 0 {
                changeIndex(i)
                next = i
                return i
            }
        }
        return next
    }
    
    /// Returns the next site in the site schedule as a suggestion of where to relocate.
    // Suggested changeIndex function: Defaults.setSiteIndex
    public func suggest(changeIndex: (Int) -> ()) -> Bodily? {
        if let i = nextIndex(changeIndex: changeIndex) {
            return sites[i]
        }
        return nil
    }

    /// Returns an array of a siteNames for each site in the schedule.
    public func getNames() -> [SiteName] {
        return sites.map({
            (site: Bodily) -> SiteName? in
            return site.name
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns array of image Ids from array of MOSites.
    public func getImageIds() -> [String] {
        return sites.map({
            (site: Bodily) -> String? in
            return site.imageIdentifier
        }).filter() { $0 != nil } as! [String]
    }
    
    /// Returns the set of sites on record union with the set of default sites
    public func unionize(deliveryMethod: DeliveryMethod) -> Set<SiteName> {
        let siteSet = Set(getNames())
        let defaults = Set<String>(PDSiteStrings.getSiteNames(for: deliveryMethod))
        return siteSet.union(defaults)
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
