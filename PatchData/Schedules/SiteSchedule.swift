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
    
    private let store: SiteStore
    private let defaults: UserDefaultsStoring
    private var sites: [Bodily]
    let siteIndexRebounder: PDIndexRebounce

    let log = PDLog<SiteSchedule>()
    
    init(
        coreDataStack: CoreDataStackWrapper,
        defaults: UserDefaultsStoring,
        siteIndexRebounder: PDIndexRebounce
    ) {
        store = SiteStore(coreDataStack)
        self.defaults = defaults
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        self.sites = store.getStoredSites(expirationInterval: exp, deliveryMethod: method)
        self.siteIndexRebounder = siteIndexRebounder
        super.init()
        handleSiteCount()
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
        return false  // if there are no sites, than it is not default
    }
    
    public func insertNew() -> Bodily? {
        if let site = createSite() {
            sites.append(site)
            store.save(site)
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
        if isDefault {
            return handleDefaultStateDuringReset()
        }
        resetSitesToDefault()
        store.save(sites)
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
            store.save(site)
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
                store.save(originalSiteAtOrder)
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
            store.save(site)
        }
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

    private var firstEmptyIndex: Index? {
        sites.firstIndex { (_ site: Bodily) -> Bool in site.hormoneCount == 0 }
    }

    private var siteIndexWithOldestHormone: Index {
        sites.reduce((oldestDate: Date(), oldestIndex: -1, iterator: 0), {
            ( sitesIterator, site) in
            let oldestDateInThisSitesHormones = getOldestDateApplied(from: site.hormoneIds)

            let newSiteIndex = sitesIterator.iterator + 1
            if oldestDateInThisSitesHormones < sitesIterator.oldestDate {
                return (oldestDateInThisSitesHormones, newSiteIndex, newSiteIndex)
            }
            return (sitesIterator.oldestDate, -1, newSiteIndex)
        }).oldestIndex
    }

    private func getOldestDateApplied(from hormoneIds: [UUID]) -> Date {
        hormoneIds.reduce(Date(), {
            (oldestDateThusFar, hormoneId) in

            if let hormone = store.entities.getHormoneById(hormoneId) {
                if let date = hormone.date as Date?, date < oldestDateThusFar {
                    return date
                }
            }
            return oldestDateThusFar
        })
    }
    
    private func createSite() -> Bodily? {
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        return store.createNewSite(expirationInterval: exp, deliveryMethod: method)
    }

    private func handleSiteCount() {
        if sites.count == 0 {
            log.info("No stored sites - resetting to default")
            reset()
            logSites()
        }
    }

    @discardableResult private func handleDefaultStateDuringReset() -> Int {
        log.warn("Resetting sites unnecessary because already default")
        return sites.count
    }

    private func resetSitesToDefault() {
        let defaultSiteNames = SiteStrings.getSiteNames(for: defaults.deliveryMethod.value)
        let previousCount = sites.count
        assignDefaultSiteProperties(options: defaultSiteNames, previousCount: previousCount)
        handleExtraSitesFromReset(previousCount: previousCount, defaultSiteNamesCount: defaultSiteNames.count)
    }

    private func assignDefaultSiteProperties(options: [String], previousCount: Int) {
        for i in 0..<options.count {
            if i < previousCount {
                setSite(&sites[i], index: i, name: options[i])
            } else if var site = insertNew() {
                setSite(&site, index: i, name: options[i])
            }
        }
    }

    private func setSite(_ site: inout Bodily, index: Index, name: String) {
        site.order = index
        site.name = name
        site.imageId = name
    }

    private func handleExtraSitesFromReset(previousCount: Int, defaultSiteNamesCount: Int) {
        if previousCount > defaultSiteNamesCount {
            resetSites(start: defaultSiteNamesCount, end: previousCount - 1)
        }
    }

    private func resetSites(start: Index, end: Index) {
        for i in start...end {
            sites[i].reset()
        }
    }

    private func logSites() {
        log.info("Logging sites...")
        for site in sites {
            log.info("Site. Id=\(site.id), Order=\(site.order), Name=\(site.name)")
        }
    }
}
