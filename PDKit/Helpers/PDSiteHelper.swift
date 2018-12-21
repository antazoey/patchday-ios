//
//  PDSiteHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 7/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation


public typealias SiteNameSet = Set<SiteName>

public class PDSiteHelper {
    
    /// Returns array of SiteNamesy from array of MOSites.
    public static func getSiteNames(_ siteArray: [MOSite]) -> [SiteName] {
        return siteArray.map({
            (site: MOSite) -> SiteName? in
            return site.getName()
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns array of image IDs from array of MOSites.
    public static func getSiteImageIDs(_ siteArray: [MOSite]) -> [String] {
        return siteArray.map({
            (site: MOSite) -> String? in
            return site.getImageIdentifer()
        }).filter() {
            $0 != nil
        } as! [String]
    }
    
    /// Returns the set of sites on record union with the set of default sites
    public static func siteNameSetUnionDefaultSites(_ siteArray: [MOSite], usingPatches: Bool) -> SiteNameSet {
        let defaultSitesSet = (usingPatches) ? Set(PDStrings.SiteNames.patchSiteNames) : Set(PDStrings.SiteNames.injectionSiteNames)
        let siteSet = Set(getSiteNames(siteArray))
        return siteSet.union(defaultSitesSet)
    }
    
    /// Returns if the given SiteName is from one of the default PatchDay sites.
    public static func isContainedInDefaults(_ name: SiteName, usingPatches: Bool) -> Bool {
        let contains: Bool = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames.contains(name) :
            PDStrings.SiteNames.injectionSiteNames.contains(name)
        return contains
    }
    
}
