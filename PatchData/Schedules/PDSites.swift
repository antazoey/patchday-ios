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
    
    override public var description: String { "Schedule for sites." }
    
    private let store: PatchDataCalling
    private let defaults: PDDefaultStoring
    private var sites: [Bodily]
    let siteIndexRebounder: PDIndexRebounce
    
    private var firstEmptyIndex: Index? {
        return sites.firstIndex {
            (_ site: Bodily) -> Bool in
            site.hormones.count == 0
        }
    }
    
    private var siteIndexWithOldestHormone: Index {
        var date = Date()
        var oldestHormoneSiteIndex = -1
        for i in 0..<count {
            let site = sites[i]
            for mone in site.hormones {
                if mone.date < date {
                    date = mone.date
                    oldestHormoneSiteIndex = i
                }
            }
        }
        return oldestHormoneSiteIndex
    }
    
    init(store: PatchDataCalling, defaults: PDDefaultStoring, siteIndexRebounder: PDIndexRebounce) {
        self.store = store
        self.defaults = defaults
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        self.sites = PatchData.createSites(expirationIntervalUD: exp, deliveryMethod: method)
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
        return Array(Set<String>(PDSiteStrings.getSiteNames(for: method)).union(names))
    }

    public var isDefault: Bool {
        let method = defaults.deliveryMethod.value
        let defaultSites = PDSiteStrings.getSiteNames(for: method)
        for i in 0..<sites.count {
            if !defaultSites.contains(sites[i].name) {
                return false
            }
        }
        return true
    }
    
    public func insertNew() -> Bodily? {
        insertNew(completion: nil)
    }

    public func insertNew(completion: (() -> ())? = nil) -> Bodily? {
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        if let site = PDSite.new(deliveryMethod: method, globalExpirationInterval: exp) {
            sites.append(site)
            return site
        }
        return nil
    }

    @discardableResult public func reset() -> Int {
        let method = defaults.deliveryMethod.value
        if isDefault {
            return sites.count
        }
        let resetNames = PDSiteStrings.getSiteNames(for: method)
        let oldCount = sites.count
        let newcount = resetNames.count
        for i in 0..<newcount {
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
            if index + 1 < sites.count - 1 {
                for i in index + 1..<sites.count {
                    sites[i].order -= 1
                }
            }
            sort()
            store.save()
        }
    }
    
    public func sort() {
        if var sites = self.sites as? [PDSite] {
            sites.sort()
        }
    }

    // MARK: - Other Public

    public func at(_ index: Index) -> Bodily? {
        sites.tryGet(at: index)
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
        siteSet = PDSiteStrings.getSiteNames(for: method)
        if var site = at(index) {
            if siteSet.contains(newId) {
                site.imageId = newId
            } else {
                sites[index].imageId = "custom"
            }
        }
        store.save()
    }

    @discardableResult private func updateIndex() -> Index {
        siteIndexRebounder.rebound(upon: nextIndex, lessThan: count)
    }
    
    @discardableResult private func updateIndex(focus: Index) -> Index {
        siteIndexRebounder.rebound(upon: focus, lessThan: count)
    }
}
