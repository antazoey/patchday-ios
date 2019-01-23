//
//  MOEstrogenMethods.swift
//  PDKit
//
//  Created by Juliya Smith on 7/13/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit

extension MOEstrogen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogen> {
        return NSFetchRequest<MOEstrogen>(entityName: "Estrogen")
    }
    
    @NSManaged internal var id: UUID?
    @NSManaged internal var date: NSDate?
    @NSManaged internal var siteNameBackUp: String?
    @NSManaged internal var siteRelationship: MOSite?
    
    
    // MARK: - Getters and setters
    
    public func setSite(_ site: MOSite?) {
        self.siteRelationship = site
        self.siteNameBackUp = nil
    }
    
    public func setDate(_ date: NSDate = NSDate()) {
        self.date = date
    }
    
    public func setId() -> UUID {
        let id = UUID()
        self.id = id
        return id
    }
    
    public func setSiteBackup(to str: String) {
        self.siteNameBackUp = str        
        self.siteRelationship = nil
    }
    
    public func getSite() -> MOSite? {
        return self.siteRelationship
    }
    
    public func getDate() -> NSDate? {
        return self.date
    }
    
    public func getId() -> UUID? {
        return self.id
    }
    
    public func getSiteNameBackUp() -> String? {
        return (siteRelationship == nil) ? siteNameBackUp : nil
    }
    
    public func getSiteName() -> String {
        let site = getSite()?.getName() ?? getSiteNameBackUp()
        switch site {
        case nil : return PDStrings.PlaceholderStrings.new_site
        case let s : return s!
        }
    }
    
    /// Sets all attributes to nil.
    public func reset() {
        id = nil
        date = nil
        siteRelationship = nil
        siteNameBackUp = nil
    }
    
    // MARK: - Strings
    
    public func expirationDate(interval: String) -> Date? {
        if let date = getDate() as Date?,
            let expires = PDDateHelper.expirationDate(from: date, interval) {
            return expires
        }
        return nil
    }
    
    public func expirationDateAsString(_ interval: String,
                                       useWords: Bool) -> String {
        if let date = getDate() as Date?,
            let expires = PDDateHelper.expirationDate(from: date,
                                                      interval) {
            return PDDateHelper.format(date: expires,
                                       useWords: useWords)
        }
        return PDStrings.PlaceholderStrings.dotdotdot
    }
    
    // MARK: - Booleans
    
    public func isExpired(_ interval: String) -> Bool {
        if let date = getDate() as Date?,
            let untilExp = PDDateHelper.expirationInterval(interval,
                                                           date: date) {
            return untilExp <= 0
        }
        return false
    }
    
    public func hasDate() -> Bool {
        return date != nil
    }
    
    public func isEmpty() -> Bool {
        return date == nil &&
            siteRelationship == nil &&
            siteNameBackUp == nil
    }
    
    /// Returns if the Estrogen is located somewhere not in the default PatchDay sites.
    public func isCustomLocated(usingPatches: Bool) -> Bool {
        let n = getSiteName()
        let names = usingPatches ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        return !names.contains(n)
    }
}
