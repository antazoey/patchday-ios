//
//  SiteSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit


public class SiteSchedule: NSObject, HormoneSiteScheduling {

    override public var description: String { "Schedule for sites." }
    
    private let store: CoreDataWrapper
    private let defaults: UserDefaultsStoring
    private var sites: [Bodily]
    let siteIndexRebounder: PDIndexRebounce
    
    private var firstEmptyIndex: Index? {
        sites.firstIndex {
            (_ site: Bodily) -> Bool in
            site.hormones.count == 0
        }
    }
    
    private var siteIndexWithOldestHormone: Index {
        sites.reduce((Date(), -1, 0), {
            ( sitesIterator, site) in
            let oldestDateInThisSitesHormones = SiteSchedule.getOldestDateApplied(from: site.hormones)
            
            let newSiteIndex = sitesIterator.2 + 1
            if oldestDateInThisSitesHormones < sitesIterator.0 {
                return (oldestDateInThisSitesHormones, newSiteIndex, newSiteIndex)
            }
            return (sitesIterator.0, -1, newSiteIndex)
        }).1
    }
    
    private static func getOldestDateApplied(from hormones: [Hormonal]) -> Date {
        hormones.reduce(Date(), {
            (oldestDateThusFar, hormone) in
            if hormone.date < oldestDateThusFar {
                return hormone.date
            }
            return oldestDateThusFar
        })
    }
    
    init(store: CoreDataWrapper, defaults: UserDefaultsStoring, siteIndexRebounder: PDIndexRebounce) {
        self.store = store
        self.defaults = defaults
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        self.sites = store.createSiteList(expiration: exp, deliveryMethod: method)
        self.siteIndexRebounder = siteIndexRebounder
        super.init()
        if sites.count == 0 {
            reset()
        }
        sort()
    }
    
    public var count: Int { sites.count }
    
    public var all: [Bodily] { sites }

    public var suggested: Bodily? {
        sites.tryGet(at: nextIndex)
    }
    
    public var occupiedSites: [Bodily] {
        var occupiedList: [Bodily] = []
        for site in sites {
            if site.isOccupied {
                occupiedList.append(site)
            }
        }
        return occupiedList
    }
    
    public var occupiedSitesIndices: [Index] {
        var indices: [Index] = []
        for site in occupiedSites {
            if let i = firstIndexOf(site) {
                indices.append(i)
            }
        }
        return indices
    }

    public var names: [SiteName] {
        sites.map({ (site: Bodily) -> SiteName in site.name })
    }

    public var imageIds: [String] {
        sites.map({ (site: Bodily) -> String in site.imageId })
    }

    public var nextIndex: Index {
        if sites.count <= 0 {
            return -1
        }
        if let siteIndex = firstEmptyIndex {
            return updateIndex(focus: siteIndex)
        }
        return siteIndexWithOldestHormone
    }

    public var unionWithDefaults: [SiteName] {
        let method = defaults.deliveryMethod.value
        return Array(Set<String>(SiteStrings.getSiteNames(for: method)).union(names))
    }

    public var isDefault: Bool {
        let method = defaults.deliveryMethod.value
        let defaultSites = SiteStrings.getSiteNames(for: method)
        for i in 0..<sites.count {
            if !defaultSites.contains(sites[i].name) {
                return false
            }
        }
        return true
    }
    
    public func insertNew() -> Bodily? {
        if let site = createSite() {
            sites.append(site)
            store.save()
            return site
        }
        return nil
    }

    public func insertNew(completion: @escaping () -> ()) -> Bodily? {
        let site = insertNew()
        completion()
        return site
    }

    public func insertNew(name: String) -> Bodily? {
        var site = insertNew()
        site?.name = name
        return site
    }

    public func insertNew(name: String, completion: @escaping () -> ()) -> Bodily? {
        let site = insertNew(name: name)
        completion()
        return site
    }

    @discardableResult public func reset() -> Int {
        let method = defaults.deliveryMethod.value
        if isDefault {
            return sites.count
        }
        let resetNames = SiteStrings.getSiteNames(for: method)
        let oldCount = sites.count
        let newCount = resetNames.count
        for i in 0..<newCount {
            if i < oldCount {
                sites[i].order = i
                sites[i].name = resetNames[i]
                sites[i].imageId = resetNames[i]
            } else if var site = insertNew() {
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
        store.save()
        return sites.count
    }

    public func delete(at index: Index) {
        if let site = at(index) {
            site.delete()
            site.reset()
            
            let start = index + 1
            let end = count - 1
            
            if start < end {
                for i in start...end {
                    sites[i].order -= 1
                }
            }
            sort()
            store.save()
        }
    }
    
    public func sort() {
        if var sites = self.sites as? [Site] {
            sites.sort()
        }
    }

    // MARK: - Other Public

    public func at(_ index: Index) -> Bodily? {
        sites.tryGet(at: index)
    }

    public func rename(at index: Index, to name: SiteName) {
        if var site = at(index) {
            site.name = name
            store.save()
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
                store.save()
            } else {
                site.order = newOrder
            }
        }
    }

    public func setImageId(at index: Index, to newId: String) {
        var siteSet: [String]
        let method = defaults.deliveryMethod.value
        siteSet = SiteStrings.getSiteNames(for: method)
        if var site = at(index) {
            if siteSet.contains(newId) {
                site.imageId = newId
            } else {
                sites[index].imageId = "custom"
            }
        }
        store.save()
    }
    
    public func firstIndexOf(_ site: Bodily) -> Index? {
        sites.firstIndex { (_ s: Bodily) -> Bool in s.isEqualTo(site) }
    }

    @discardableResult private func updateIndex() -> Index {
        siteIndexRebounder.rebound(upon: nextIndex, lessThan: count)
    }
    
    @discardableResult private func updateIndex(focus: Index) -> Index {
        siteIndexRebounder.rebound(upon: focus, lessThan: count)
    }
    
    private func createSite() -> Bodily? {
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        return store.createSite(expiration: exp, deliveryMethod: method)
    }
}
