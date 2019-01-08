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
        return """
               Schedule for maintaining sites
               for estrogen patches or injections.
               """
    }
    
    public var sites: [MOSite] = []
    internal var next: Index = 0
    internal var usingPatches: Bool = true
    
    init() {
        super.init(type: .site)
        sites = self.mos as! [MOSite]
        mos = []
        filterEmpty()
        if sites.count == 0 {
            new()
        }
        sort()
    }
    
    // MARK: - Overrides
    
    override public func count() -> Int {
        return sites.count
    }
    
    /// Appends the the new site to the sites and returns it.
   override public func insert(completion: (() -> ())? = nil) -> MOSite? {
        if let site = PatchData.insert(type.rawValue) as? MOSite {
            site.setOrder(to: Int16(sites.count))
            sites.append(site)
            PatchData.save()
            return site
        }
        return nil
    }

    /// Resets the site array a default list of sites.
    override public func reset(completion: (() -> ())? = nil) {
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
                sites[i].setOrder(to: Int16(i))
                sites[i].setName(to: resetNames[i])
                sites[i].setImageIdentifier(to: resetNames[i])
            } else if let site = insert() {
                site.setOrder(to: Int16(i))
                site.setName(to: resetNames[i])
                site.setImageIdentifier(to: resetNames[i])
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
    
    /// Generates a generic list of MOSites when there are none in store.
    override public func new() {
        var sites: [MOSite] = []
        typealias SiteNames = PDStrings.SiteNames
        var names = (usingPatches) ?
            SiteNames.patchSiteNames :
            SiteNames.injectionSiteNames
        for i in 0..<names.count {
            if let site = insert() {
                site.setOrder(to: Int16(i))
                site.setName(to: names[i])
                site.setImageIdentifier(to: names[i])
                sites.append(site)
            }
        }
        PatchData.save()
        self.sites = sites
    }
    
    /// Removes all sites with empty or nil names from the sites.
    override public func filterEmpty() {
        sites = sites.filter() {
            $0.getName() != ""
                && $0.getName() != nil
                && $0.getOrder() > -1
        }
    }
    
    override public func sort() {
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
        let site = insert()
        site?.setName(to: name)
        site?.setImageIdentifier(to: name)
        return site
    }
    
    /// Sets a the siteName for the site at the given index.
    public func setName(at index: Index, to name: String) {
        if index >= 0 && index < sites.count {
            sites[index].setName(to: name)
            PatchData.save()
        }
    }
    
    /// Swaps the indices of two sites by setting the order.
    public func setOrder(at index: Index, to newOrder: Int16) {
        let newIndex = Index(newOrder)
        if index >= 0 && index < sites.count && newIndex < sites.count && newIndex >= 0 {
            // Make sure index is correct both before and after swap
            sort()
            sites[index].setOrder(to: newOrder)
            sites[newIndex].setOrder(to: Int16(index))
            sort()
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
    
    /// Returns the next site for scheduling in the site schedule.
    public func nextIndex(changeIndex: (Int) -> ()) -> Index? {
        if (next < 0) {
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
