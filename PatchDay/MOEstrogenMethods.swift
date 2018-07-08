//
//  MOEstrogen+CoreDataProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
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

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var siteRelationship: MOSite?

    // MARK: - Getters and setters
    
    public func setSite(with site: MOSite) {
        self.siteRelationship = site
    }
    
    public func setDate(with date: NSDate) {
        self.date = date
    }

    public func setID(with newID: UUID) {
        self.id = newID
    }
    
    public func getSite() -> MOSite? {
        return self.siteRelationship
    }
    
    public func getDate() -> NSDate? {
        return self.date
    }
    
    public func getID() -> UUID? {
        return self.id
    }
    
    public func reset() {
        date = nil
        siteRelationship = nil
    }
    
    // MARK: - Strings
    
    public func string() -> String {
        var estroString = getDatePlacedAsString()
        if let site = getSite(), let siteName = site.getName() {
            estroString += ", " + siteName
        }
        return estroString
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = date else {
            return PDStrings.PlaceholderStrings.unplaced
        }
        return PDDateHelper.format(date: dateAdded as Date, useWords: true)
    }
    
    public func expirationDateAsString(_ intervalStr: String, useWords: Bool) -> String {
        if let date = getDate(), let expires = PDDateHelper.expirationDate(from: date as Date, intervalStr) {
            return PDDateHelper.format(date: expires, useWords: useWords)
        }
        
        return PDStrings.PlaceholderStrings.dotdotdot
    }
    
    // MARK: - Booleans
    
    public func isExpired(_ intervalStr: String) -> Bool {
        if let date = getDate(), let intervalUntilExpiration = PDDateHelper.expirationInterval(intervalStr, date: date as Date) {
            return intervalUntilExpiration <= 0
        }
        return false
    }
    
    public func hasNoDate() -> Bool {
        return date == nil
    }
    
    public func isEmpty() -> Bool {
        return date == nil && siteRelationship == nil
    }
    
    public func isCustomLocated() -> Bool {
        if let site = getSite(), let siteName = site.getName() {
            if UserDefaultsController.usingPatches() {
                return !PDStrings.SiteNames.patchSiteNames.contains(siteName)
            }
            else {
                return !PDStrings.SiteNames.injectionSiteNames.contains(siteName)
            }
        }
        return false
    }
    

}
