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

public class SiteSchedule: NSObject, PDScheduling {
    
    override public var description: String {
        return """
               Schedule for maintaining sites
               for estrogen patches or injections.
               """
    }
    
    public var sites: [MOSite] = []
    internal var next: Index = 0
    internal var usingPatches: Bool = true
    
    override init() {
        super.init()
        let mos_opt: [NSManagedObject]? = PatchData.loadMOs(for: .site)
        if let mos = mos_opt {
            sites = mos as! [MOSite]
        }
        if sites.count == 0 {
            new()
        }
        filterEmpty()
        sort()
    }
    
    // MARK: - Overrides
    
    public func count() -> Int {
        return sites.count
    }
    
    /// Appends the the new site to the sites and returns it.
   public func insert(completion: (() -> ())? = nil) -> NSManagedObject? {
    let type = PDEntity.site.rawValue
        if let site = PatchData.insert(type) as? MOSite {
            site.setOrder(Int16(sites.count))
            sites.append(site)
            PatchData.save()
            return site
        }
        return nil
    }

    /// Resets the site array a default list of sites.
    public func reset(completion: (() -> ())? = nil) {
        if (isDefault(usingPatches: usingPatches)) {
            return
        }
        let resetNames: [String] = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        let oldCount = sites.count
        let newcount = resetNames.count
        for i in 0..<newcount {
            if i < oldCount {
                sites[i].setOrder(Int16(i))
                sites[i].setName(resetNames[i])
                sites[i].setImageIdentifier(resetNames[i])
            } else if let site = insert() as? MOSite {
                site.setName(resetNames[i])
                site.setImageIdentifier(resetNames[i])
            }
        }
        if oldCount > resetNames.count {
            for i in resetNames.count..<oldCount {
                sites[i].reset()
            }
        }
        filterEmpty()
        sort()
        PatchData.save()
        if let comp = completion {
            comp()
        }
    }
    
    /// Deletes the site at the given index.
    public func delete(at index: Index) {
        if index >= 0 && index < sites.count {
            loadBackupSiteName(from: sites[index])
            PatchData.getContext().delete(sites[index])
            sites[index].reset()
        }
        if (index+1) < (sites.count-1) {
            for i in (index+1)..<sites.count {
                sites[i].decrement()
            }
        }
        filterEmpty()
        sort()
        PatchData.save()
    }
    
    /// Generates a generic list of MOSites when there are none in store.
    public func new() {
        var sites: [MOSite] = []
        typealias SiteNames = PDStrings.SiteNames
        var names = (usingPatches) ?
            SiteNames.patchSiteNames :
            SiteNames.injectionSiteNames
        for i in 0..<names.count {
            if let site = insert() as? MOSite {
                site.setName(names[i])
                site.setImageIdentifier(names[i])
                sites.append(site)
            }
        }
        PatchData.save()
        sort()
        self.sites = sites
    }
    
    /// Removes all sites with empty or nil names from the sites.
    public func filterEmpty() {
        var sites_new: [MOSite] = []
        sites.forEach() {
            if $0.getName() == ""
                || $0.getName() == nil
                || $0.getOrder() < 0 {
                PatchData.getContext().delete($0)
            } else {
                sites_new.append($0)
            }
        }
        sites = sites_new
        PatchData.save()
    }
    
    public func sort() {
        sites.sort(by: <)
    }

    // MARK: - Other Public

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
        let site = insert() as? MOSite
        site?.setName(name)
        site?.setImageIdentifier(name)
        return site
    }
    
    /// Sets a the siteName for the site at the given index.
    public func setName(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].setName(name)
            PatchData.save()
        }
    }
    
    /// Swaps the indices of two sites by setting the order.
    public func setOrder(at index: Index, to newOrder: Int16) {
        let newIndex = Index(newOrder)
        if index >= 0 && index < sites.count && newIndex < sites.count && newIndex >= 0 {
            // Make sure index is correct both before and after swap
            sort()
            sites[index].setOrder(newOrder)
            sites[newIndex].setOrder(Int16(index))
            sort()
            PatchData.save()
        }
    }
    
    /// Sets the site image Id for the site at the given index.
    public func setImageId(at index: Index, to newId: String, usingPatches: Bool) {
        let site_set = usingPatches ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        if site_set.contains(newId), index >= 0 && index < sites.count {
            sites[index].setImageIdentifier(newId)
            PatchData.save()
        }
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
            if let estros = sites[i].estrogenRelationship,
                estros.count == 0 {
                changeIndex(i)
                next = i
                return i
            }
        }
        return next
    }
    
    /// Returns the next site in the site schedule as a suggestion of where to relocate.
    // Suggested changeIndex function: Defaults.setSiteIndex
    public func suggest(changeIndex: (Int) -> ()) -> MOSite? {
        if let i = nextIndex(changeIndex: changeIndex) {
            return sites[i]
        }
        return nil
    }

    /// Returns an array of a siteNames for each site in the schedule.
    public func getNames() -> [SiteName] {
        return sites.map({
            (site: MOSite) -> SiteName? in
            return site.getName()
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns array of image Ids from array of MOSites.
    public func getImageIds() -> [String] {
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
        let defaultSites = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        let def_c = defaultSites.count
        let sites_c = count()
        if sites_c != def_c {
            return false
        }
        for i in 0..<def_c {
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
    
    // MARK: Private
    
    /// Set the siteBackUpName in every estrogen.
    private func loadBackupSiteName(from site: MOSite) {
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
}
