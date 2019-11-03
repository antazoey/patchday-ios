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
        if let site = at(index) {
            site.delete()
            site.reset()
            if index + 1 < sites.count - 1 {
                for i in index + 1..<sites.count {
                    sites[i].order -= 1
                }
            }
            sort()
            PatchData.save()
        }
    }
    
    public func sort() {
        if var sites = self.sites as? [PDSite] {
            sites.sort()
        }
    }

    // MARK: - Other Public

    public func at(_ index: Index) -> Bodily? {
        return sites.tryGet(at: index)
    }

    public func get(for name: String) -> Bodily? {
        if let i = names.firstIndex(of: name) {
            return sites[i]
        }
        return nil
    }

    public func rename(at index: Index, to name: String) {
        if var site = at(index) {
            site.name = name
            PatchData.save()
        }
    }

    public func reorder(at index: Index, to newOrder: Int) {
        if var site = at(index) {
            if var originalSiteAtOrder = at(newOrder) {
                // Make sure index is correct both before and after swap
                sort()
                site.order = newOrder
                originalSiteAtOrder.order = index + 1
                sort()
                PatchData.save()
            } else {
                site.order = newOrder
            }
        }
    }

    public func setImageId(at index: Index, to newId: String, deliveryMethod: DeliveryMethod) {
        var site_set: [String]
        site_set = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if var site = at(index) {
            if site_set.contains(newId) {
                site.imageId = newId
            } else {
                sites[index].imageId = "custom"
            }
        }
        PatchData.save()
    }

    public func unionWithDefaults(deliveryMethod: DeliveryMethod) -> Set<SiteName> {
        return Set<String>(PDSiteStrings.getSiteNames(for: deliveryMethod)).union(names)
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
