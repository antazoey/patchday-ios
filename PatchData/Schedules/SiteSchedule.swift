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
    private var resetWhenEmpty: Bool
    
    private let store: SiteStoring
    private let defaults: UserDefaultsWriting
    private var sites: [Bodily]

    let log = PDLog<SiteSchedule>()
    
    init(store: SiteStoring, defaults: UserDefaultsWriting, resetWhenEmpty: Bool = true) {
        self.store = store
        self.defaults = defaults
        self.resetWhenEmpty = resetWhenEmpty
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        self.sites = store.getStoredSites(expiration: exp, method: method)
        super.init()
        handleSiteCount()
        sort()
    }
    
    public var count: Int { sites.count }
    
    public var all: [Bodily] { sites }

    public var suggested: Bodily? {
        guard count > 0 else { return nil }
        if let trySite = siteIndexSuggested {
            return trySite
        } else if let trySite = firstEmptyFromSiteIndex {
            return trySite
        }
        return siteWithOldestHormone
    }
    
    public var nextIndex: Index {
        sites.firstIndex(where: { b in
            if let suggestedSite = suggested {
                return suggestedSite.id == b.id
            }
            return false
        }) ?? -1
    }

    public var names: [SiteName] {
        sites.map({ (site: Bodily) -> SiteName in site.name })
    }

    public var isDefault: Bool {
        guard count > 0 else { return false }
        let method = defaults.deliveryMethod.value
        let defaultSites = SiteStrings.getSiteNames(for: method)
        for name in names {
            if !defaultSites.contains(name) {
                return false
            }
        }
        return true
    }

    @discardableResult
    public func insertNew(name: String, save: Bool, onSuccess: (() -> ())?) -> Bodily? {
        if var site = createSite(save) {
            site.name = name
            sites.append(site)
            onSuccess?()
            return site
        }
        return nil
    }

    @discardableResult
    public func reset() -> Int {
        if isDefault {
            log.warn("Resetting sites unnecessary because already default")
            return sites.count
        }
        resetSitesToDefault()
        store.pushLocalChangesToManagedContext(sites, doSave: true)
        return sites.count
    }

    public func delete(at index: Index) {
        if let site = at(index) {
            log.info("Deleting site at index \(index)")
            store.delete(site)
            let start = index + 1
            let end = count - 1
            if start < end {
                for i in start...end {
                    sites[i].order -= 1
                }
            }
            sort()
        }
    }
    
    public func sort() {
        sites.sort(by: SiteComparator.lessThan)
    }

    public func at(_ index: Index) -> Bodily? {
        sites.tryGet(at: index)
    }

    public func get(by id: UUID) -> Bodily? {
        sites.first(where: { s in s.id == id })
    }

    public func getName(by id: UUID) -> SiteName? {
        get(by: id)?.name
    }

    public func rename(at index: Index, to name: SiteName) {
        if var site = at(index) {
            site.name = name
            store.pushLocalChangesToManagedContext([site], doSave: true)
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
                store.pushLocalChangesToManagedContext([originalSiteAtOrder], doSave: true)
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
                sites[index].imageId = SiteStrings.CustomSiteId
            }
            store.pushLocalChangesToManagedContext([site], doSave: true)
        }
    }
    
    public func firstIndexOf(_ site: Bodily) -> Index? {
        sites.firstIndex { (_ s: Bodily) -> Bool in s.isEqualTo(site) }
    }

    @discardableResult
    private func updateIndex() -> Index {
        defaults.replaceStoredSiteIndex(to: nextIndex, siteCount: count)
    }
    
    @discardableResult
    private func updateIndex(to newIndex: Index) -> Index {
        defaults.replaceStoredSiteIndex(to: newIndex, siteCount: count)
    }
    
    private var siteIndexSuggested: Bodily? {
        if let site = at(defaults.siteIndex.value), site.hormoneCount == 0 {
            return site
        }
        return nil
    }

    private var firstEmptyFromSiteIndex: Bodily? {
        var siteIterator = defaults.siteIndex.value
        for _ in 0..<count {
            if let site = at(siteIterator), site.hormoneCount == 0 {
                return site
            }
            siteIterator = (siteIterator + 1) % count
        }
        return nil
    }

    private var siteWithOldestHormone: Bodily? {
        sites.reduce((oldestDate: Date(), oldest: nil, iterator: 0), {
            (b, site) in

            if let oldestDateInThisSitesHormones = getOldestHormoneDate(from: site.id),
               oldestDateInThisSitesHormones < b.oldestDate, let site = at(b.iterator) {

                return (oldestDateInThisSitesHormones, site, b.iterator + 1)
            }
            return (b.oldestDate, b.oldest, b.iterator + 1)
        }).oldest
    }

    private func getOldestHormoneDate(from siteId: UUID) -> Date? {
        var hormones = store.getRelatedHormones(siteId)
        hormones.sort(by: {
            if let d1 = $0.date, let d2 = $1.date {
                return d1 < d2
            }
            return false
        })
        return hormones.tryGet(at: 0)?.date
    }
    
    private func createSite(_ save: Bool) -> Bodily? {
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        return store.createNewSite(expiration: exp, method: method, doSave: save)
    }

    private func handleSiteCount() {
        if resetWhenEmpty && sites.count == 0 {
            log.info("No stored sites - resetting to default")
            reset()
            logSites()
        }
    }

    private func resetSitesToDefault() {
        let defaultSiteNames = SiteStrings.getSiteNames(for: defaults.deliveryMethod.value)
        let previousCount = sites.count
        assignDefaultProperties(options: defaultSiteNames)
        deleteExtraSitesIfNeeded(previousCount: previousCount, newCount: defaultSiteNames.count)
    }

    private func assignDefaultProperties(options: [String]) {
        for i in 0..<options.count {
            let name = options[i]
            if var site = at(i) {
                setSite(&site, index: i, name: name)
            } else {
                insertNew(name: name, save: false, onSuccess: nil)
            }
        }
    }
    
    private func deleteExtraSitesIfNeeded(previousCount: Int, newCount: Int) {
        if newCount < previousCount {
            deleteSites(start: newCount, end: previousCount - 1)
        }
    }

    private func setSite(_ site: inout Bodily, index: Index, name: String) {
        site.order = index
        site.name = name
        site.imageId = name
    }

    private func deleteSites(start: Index, end: Index) {
        for i in start...end {
            if let site = sites.tryGet(at: i) {
                site.reset()
                store.delete(site)
            }
        }
    }

    private func logSites() {
        var sitesDescription = "The Site Schedule contains:"
        for site in sites {
            sitesDescription.append("\nSite. Id=\(site.id), Order=\(site.order), Name=\(site.name)")
        }
        if sitesDescription.last != ":" {
            log.info(sitesDescription)
        }
    }
}
