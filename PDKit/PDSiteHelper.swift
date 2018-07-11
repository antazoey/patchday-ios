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
    
    
    public static func getSiteNames(_ siteArray: [MOSite]) -> [SiteName] {
        return siteArray.map({
            (site: MOSite) -> SiteName? in
            return site.getName()
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns the set of sites on record union with the set of default sites
    public static func siteNameSetUnionDefaultSites(_ siteArray: [MOSite], usingPatches: Bool) -> SiteNameSet {
        let defaultSitesSet = (usingPatches) ? Set(PDStrings.SiteNames.patchSiteNames) : Set(PDStrings.SiteNames.injectionSiteNames)
        let siteSet = Set(getSiteNames(siteArray))
        return siteSet.union(defaultSitesSet)
    }
    
}
