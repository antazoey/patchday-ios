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

public typealias SiteNameSet = Set<SiteName>

public class SiteSchedule: PDScheduleProtocol {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOSite array."
    }
    
    public var sites: [MOSite]
    
    override init() {
        sites = PatchData.loadMOs(for: .site) as? [MOSite] ?? []
        sites = SiteSchedule.filterEmpty(from: sites)
        if sites.count == 0 {
            sites = SiteSchedule.new()
        }
        sites.sort(by: <)
    }
    
    // MARK: - Override base class
    
    override public func count() -> Int {
        return sites.count
    }
    
    override public func insert() -> MOSite? {
        let n = PDStrings.PlaceholderStrings.new_site
        return SiteSchedule.insert(name: n, sites: &sites)
    }
    
    /// Resets the site array a default list of sites.
    override public func reset() {
        let usingPatches = UserDefaultsController.usingPatches()
        let resetNames: [String] = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        let oldCount = sites.count
        let newcount = resetNames.count
        let entity = PDStrings.CoreDataKeys.siteEntityName
        for i in 0..<newcount {
            if i < sites.count {
                sites[i].setOrder(to: Int16(i))
                sites[i].setName(to: resetNames[i])
                sites[i].setImageIdentifier(to: resetNames[i])
            } else if let site = PatchData.insert(entity) as? MOSite {
                site.setOrder(to: Int16(i))
                site.setName(to: resetNames[i])
                site.setImageIdentifier(to: resetNames[i])
                sites.append(site)
            }
        }
        if oldCount > resetNames.count {
            for i in resetNames.count..<oldCount {
                sites[i].reset()
            }
        }
        sites = SiteSchedule.filterEmpty(from: sites)
        sites.sort(by: <)
        PatchData.save()
    }

    // MARK: - Public
    
    public func getSites() -> [MOSite] {
        return sites
    }

    /// Returns the site at the given index.
    public func getSite(at index: Index) -> MOSite? {
        if index >= 0 && index < sites.count {
            return sites[index]
        }
        return nil
    }
    
    /// Returns the MOSite for the given name. Appends new site with given name if doesn't exist.
    public func getSite(for name: String) -> MOSite? {
        if let index = getNames().index(of: name) {
            return sites[index]
        }
        // Append new site
        return SiteSchedule.insert(name: name, sites: &sites)
    }
    
    /// Returns the next site for scheduling in the site schedule.
    public func nextIndex(current: Index) -> Index? {
        if sites.count <= 0 || current < 0 {
            return nil
        }
        var r: Index = (current < sites.count) ? current : 0
        for _ in 0..<sites.count {
            // Return site that has no estros
            if sites[r].estrogenRelationship?.count == 0 {
                UserDefaultsController.setSiteIndex(to: r)
                return r
            } else {
                r = UserDefaultsController.getSiteIndex()
            }
        }
        return min(current, sites.count-1)
    }
    
    /// Sets a the siteName for the site at the given index.
    public func setName(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].setName(to: name)
            PatchData.save()
        }
    }
    
    /// Sets the site order for the site at the given index.
    public func setOrder(at index: Index, to newOrder: Int16) {
        let newIndex = Index(newOrder)
        if index >= 0 && index < sites.count && newIndex < sites.count && newIndex >= 0 {
            sites.sort(by: <)
            sites[index].setOrder(to: newOrder)
            sites[newIndex].setOrder(to: Int16(index))
            sites.sort(by: <)
            PatchData.save()
        }
    }
    
    /// Sets the site image ID for the site at the given index.
    public func setImageID(at index: Index, to newID: String, usingPatches: Bool) {
        let site_set = usingPatches ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        if site_set.contains(newID), index >= 0 && index < sites.count {
            sites[index].setImageIdentifier(to: newID)
            PatchData.save()
        }
    }
    
    /// Set the siteBackUpName in every estrogen.
    public func loadBackupSiteName(from site: MOSite) {
        if site.isOccupied(),
            let estroSet = site.estrogenRelationship {
            for estro in Array(estroSet) {
                let e = estro as! MOEstrogen
                if let n = site.getName() {
                    e.setSiteBackup(to: n)
                }
            }
        }
    }
    
    /// Returns an array of a siteNames for each site in the schedule.
    public func getNames() -> [SiteName] {
        return sites.map({
            (site: MOSite) -> SiteName? in
            return site.getName()
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns array of image IDs from array of MOSites.
    public func getImageIDs() -> [String] {
        return sites.map({
            (site: MOSite) -> String? in
            return site.getImageIdentifer()
        }).filter() {
            $0 != nil
            } as! [String]
    }
    
    /// Returns the set of sites on record union with the set of default sites
    public func unionDefault(usingPatches: Bool) -> SiteNameSet {
        let defaultSitesSet = (usingPatches) ? Set(PDStrings.SiteNames.patchSiteNames) : Set(PDStrings.SiteNames.injectionSiteNames)
        let siteSet = Set(getNames())
        return siteSet.union(defaultSitesSet)
    }
    
    /// Returns if the sites in the site schedule are the same as the default sites.
    public func isDefault(usingPatches: Bool) -> Bool {
        let defaultSites = (usingPatches) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        let c = defaultSites.count
        if sites.count != c {
            return false
        }
        for i in 0..<c {
            if let n = sites[i].getName() {
                if n != defaultSites[i] {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }

    /// Removes all sites with empty or nil names from the sites.
    public static func filterEmpty(from sites: [MOSite]) -> [MOSite] {
        return sites.filter() { $0.getName() != ""
            && $0.getName() != nil
            && $0.getOrder() != -1 }
    }
    
    /// Appends the the new site to the sites and returns it.
    public static func insert(name: String, sites: inout [MOSite]) -> MOSite? {
        let entity = PDStrings.CoreDataKeys.siteEntityName
        if let site = PatchData.insert(entity) as? MOSite {
            site.setName(to: name)
            site.setImageIdentifier(to: name)
            site.setOrder(to: Int16(sites.count))
            sites.append(site)
            PatchData.save()
            return site
        }
        return nil
    }
    
    /// Deletes the site at the given index.
    public func delete(at index: Index) {
        if index >= 0 && index < sites.count {
            loadBackupSiteName(from: sites[index])
            sites[index].reset()
        }
        if (index+1) < (sites.count-1) {
            for i in (index+1)..<sites.count {
                sites[i].decrement()
            }
        }
        sites = sites.filter() { $0.getOrder() != -1 && $0.getName() != ""}
        PatchData.save()
    }
    
    // MARK: Private
    
    /// Generates a generic list of MOSites when there are none in store.
    private static func new() -> [MOSite] {
        var sites: [MOSite] = []
        var names = (UserDefaultsController.usingPatches()) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        for i in 0..<names.count {
            let entity = PDStrings.CoreDataKeys.siteEntityName
            if let site = PatchData.insert(entity) as? MOSite {
                site.setOrder(to: Int16(i))
                site.setName(to: names[i])
                site.setImageIdentifier(to: names[i])
                sites.append(site)
            }
        }
        PatchData.save()
        return sites
    }
    
    /// Prints the every site and order (for debugging).
    public func printSites() {
        print("PRINTING SITES")
        print("--------------")
        for site in sites {
            print("Order: " + String(site.getOrder()))
            if let n = site.getName() {
                print("Name: " + n)
            } else {
                print("Unnamed")
            }
            print("---------")
        }
        print("*************")
    }
}
