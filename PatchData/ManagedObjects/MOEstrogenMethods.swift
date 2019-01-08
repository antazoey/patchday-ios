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

extension MOEstrogen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogen> {
        return NSFetchRequest<MOEstrogen>(entityName: "Estrogen")
    }
    
    @NSManaged internal var id: UUID?
    @NSManaged internal var date: NSDate?
    @NSManaged internal var siteNameBackUp: String?
    @NSManaged internal var siteRelationship: MOSite?
    
    
    // MARK: - Getters and setters
    
    public func setSite(with site: MOSite?) {
        self.siteRelationship = site
        self.siteNameBackUp = nil
    }
    
    public func setDate(with date: NSDate) {
        self.date = date
    }
    
    public func setID() {
        self.id = UUID()
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
    
    public func getID() -> UUID {
        if self.id == nil {
            setID()
        }
        return self.id!
    }
    
    public func getSiteNameBackUp() -> String? {
        if siteRelationship == nil {
            return self.siteNameBackUp
        }
        return nil
    }
    
    public func getSiteName() -> String {
        if let site = getSite(), let name = site.getName() {
            return name
        } else if let name = getSiteNameBackUp() {
            return name
        } else {
            return PDStrings.PlaceholderStrings.new_site
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
    
    public func string() -> String {
        var estroString = getDatePlacedAsString()
        if let site = getSite(),
            let siteName = site.getName() {
            estroString += ", " + siteName
        }
        return estroString
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = date else {
            return PDStrings.PlaceholderStrings.unplaced
        }
        return PDDateHelper.format(date: dateAdded as Date,
                                   useWords: true)
    }
    
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
            let expires = PDDateHelper.expirationDate(from: date, interval) {
            return PDDateHelper.format(date: expires, useWords: useWords)
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
        let contains: Bool = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames.contains(n) :
            PDStrings.SiteNames.injectionSiteNames.contains(n)
        return contains
    }
}
