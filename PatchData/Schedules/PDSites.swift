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
    
    override public var description: String { return "Schedule for sites." }
    
    private var sites: [Bodily]
    var next: Index = 0
    let siteIndexRebounder: PDIndexRebounce
    
    init(deliveryMethod: DeliveryMethod,
         globalExpirationInterval: ExpirationIntervalUD,
         siteIndexRebounder: PDIndexRebounce
    ) {
        self.sites = PatchData.createSites(
            expirationIntervalUD: globalExpirationInterval,
            deliveryMethod: deliveryMethod
        )
        self.siteIndexRebounder = siteIndexRebounder
        super.init()
        if sites.count == 0 {
            let exp = globalExpirationInterval
            reset(deliveryMethod: deliveryMethod, interval: exp)
        }
        sort()
    }
    
    public var count: Int { return sites.count }
    
    public var all: [Bodily] { return sites }

    public var suggested: Bodily? {
        if let i = nextIndex { return sites[i] }
        return nil
    }

    public var names: [SiteName] {
        return sites.map({ (site: Bodily) -> SiteName in return site.name })
    }

    public var imageIds: [String] {
        return sites.map({ (site: Bodily) -> String in return site.imageId })
    }

    public var nextIndex: Index? {
        if next < 0 {
            next = siteIndexRebounder.rebound(upon: 0, lessThan: sites.count)
        }
        if sites.count <= 0 {
            return nil
        }
        for i in 0..<sites.count {
            if sites[i].hormones.count == 0 {
                next = siteIndexRebounder.rebound(upon: i, lessThan: sites.count)
            }
        }
        return next
    }
    
    public func swap(_ sourceIndex: Index, with destinationIndex: Index) {
        let destinationOccupant = sites[destinationIndex]
        sites[destinationIndex] = sites[sourceIndex]
        sites[sourceIndex] = destinationOccupant
    }

    public func insertNew(
        deliveryMethod: DeliveryMethod,
        globalExpirationInterval: ExpirationIntervalUD,
        completion: (() -> ())? = nil
    ) -> Bodily? {
        let i = globalExpirationInterval
        if let site = PDSite.new(deliveryMethod: deliveryMethod, globalExpirationInterval: i) {
            sites.append(site)
            return site
        }
        return nil
    }

    @discardableResult public func reset(
        deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD
    ) -> Int {
        if isDefault(deliveryMethod: deliveryMethod) {
            return sites.count
        }
        let resetNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
        let oldCount = sites.count
        let newcount = resetNames.count
        for i in 0..<newcount {
            if i < oldCount {
                sites[i].order = i
                sites[i].name = resetNames[i]
                sites[i].imageId = resetNames[i]
            } else if var site = insertNew(
                deliveryMethod: deliveryMethod,
                globalExpirationInterval: interval
                ) {
                site.name = resetNames[i]
                site.imageId = resetNames[i]
            }
        }
        if oldCount > resetNames.count {
            for i in resetNames.count..<oldCount {
                sites[i].reset()
            }
        }
        sort()
        PatchData.save()
        return sites.count
    }

    public func delete(at index: Index) {
        switch (index) {
        case 0..<sites.count :
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
    
    public func sort() {
        if var sites = self.sites as? [PDSite] {
            sites.sort()
        }
    }

    // MARK: - Other Public

    public func at(_ index: Index) -> Bodily? {
        if index >= 0 && index < sites.count {
            return sites[index]
        }
        return nil
    }

    public func get(for name: String) -> Bodily? {
        if let i = names.firstIndex(of: name) {
            return sites[i]
        }
        return nil
    }

    public func rename(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].name = name
            PatchData.save()
        }
    }

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

    public func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod) {
        var site_set: [String]
        site_set = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if site_set.contains(newId), index >= 0 && index < sites.count {
            sites[index].imageId = newId
        } else {
            sites[index].imageId = "custom"
        }
        PatchData.save()
    }

    public func unionWithDefaults(deliveryMethod: DeliveryMethod) -> Set<SiteName> {
        let defaults = Set<String>(PDSiteStrings.getSiteNames(for: deliveryMethod))
        return Set(names).union(defaults)
    }

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
