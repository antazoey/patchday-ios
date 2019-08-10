//
//  MOEstrogen.swift
//  PDKit
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit

@objc(MOEstrogen)
public class MOEstrogen: NSManagedObject, TimeReleased {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogen> {
        return NSFetchRequest<MOEstrogen>(entityName: "Estrogen")
    }
    
    @NSManaged var siteRelationship: MOSite?
    @NSManaged public var id: UUID?
    @NSManaged public var date: NSDate?
    @NSManaged public var siteNameBackUp: String?

    // Note: nil is greater than all for MOEstrogens
    
    public static func < (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return (lhs.date as Date?)! < (rhs.date as Date?)!
        }
    }
    
    public static func > (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return (lhs.date as Date?)! > (rhs.date as Date?)!
        }
    }
    
    public static func == (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return (lhs.date as Date?)! == (rhs.date as Date?)!
        }
    }
    
    public static func != (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return (lhs.date as Date?)! != (rhs.date as Date?)!
        }
    }
    
    // MARK: - Getters and setters
    
    public var site: Bodily? {
        get {
            return siteRelationship
        }
        set {
            siteRelationship = newValue as? MOSite
        }
    }
    
    public func setSite(_ site: Bodily?) {
        if let s = site as? MOSite {
            self.siteRelationship = s
            self.siteNameBackUp = nil
        }
    }
    
    public func setDate() {
        self.date = NSDate()
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
        let site = getSite()?.name ?? getSiteNameBackUp()
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
    
    public func expirationDate(interval: ExpirationIntervalUD) -> Date? {
        if let date = getDate() as Date?,
            let expires = PDDateHelper.expirationDate(from: date, interval.hours) {
            return expires
        }
        return nil
    }
    
    public func expirationDateAsString(_ interval: ExpirationIntervalUD, useWords: Bool) -> String {
        if let date = getDate() as Date?,
            let expires = PDDateHelper.expirationDate(from: date, interval.hours) {
            return PDDateHelper.format(date: expires, useWords: useWords)
        }
        return PDStrings.PlaceholderStrings.dotdotdot
    }
    
    // MARK: - Booleans
    
    public func isExpired(_ interval: ExpirationIntervalUD) -> Bool {
        if let date = getDate() as Date?,
            let untilExp = PDDateHelper.expirationInterval(interval.hours, date: date) {
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
    public func isCustomLocated(deliveryMethod: DeliveryMethod) -> Bool {
        let n = getSiteName()
        return !PDSiteStrings.getSiteNames(for: deliveryMethod).contains(n)
    }
}
