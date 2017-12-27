//
//  MOEstrogenDeliveryMethods.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

    //Description: MOEstrogenDelivery is a managed object class that represents either a Patch or an Injection.  MOEstrogenDelivery objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the location placed or injected.  MOEstrogenDelivery.expirationDate() or MOEstrogenDelivery.expirationDateAsString() are useful in the Schedule.

    // This file is an extension of the Patch object to include useful methods.

extension MOEstrogenDelivery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogenDelivery> {
        return NSFetchRequest<MOEstrogenDelivery>(entityName: PDStrings.entityName)
    }

    //MARK: - setters
    
   public func setDatePlaced(withDate: Date) {
        self.datePlaced = withDate
    }
    
    public func setDatePlaced(withString: String) {
        let dateFormatter = DateFormatter()
        self.datePlaced = dateFormatter.date(from: withString)
    }
    
    public func setLocation(with: String) {
        self.location = with
    }
    
    // MARK: - getters
    
    public func getdate() -> Date? {
        return self.datePlaced
    }
    
    public func getLocation() -> String {
        guard let location = self.location else {
            return PDStrings.unplaced_string
        }
        return location
    }
    
    // MARK: - mutators
    
    public func progressToNow() {
        self.datePlaced = Date()
    }
    
    public func reset() {
        self.datePlaced = nil
        self.location = PDStrings.unplaced_string
    }
    
    // MARK: - strings
    
    public func string() -> String {
        return self.getDatePlacedAsString() + "," + self.getLocation()
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = self.datePlaced else {
            return PDStrings.unplaced_string
        }
        return MOEstrogenDelivery.makeDateString(from: dateAdded)
    }
    
    public func expirationDateAsString(timeInterval: String) -> String {
        if self.getdate() == nil {
            return PDStrings.hasNoDate
        }
        let expires = self.expirationDate(timeInterval: timeInterval)
        return MOEstrogenDelivery.makeDateString(from: expires)
    }
    
    // MARK: - booleans
    
    public func isEmpty() -> Bool {
        if self.location == "Unplaced" {
            self.location = "unplaced"
        }
        return self.datePlaced == nil && self.location == "unplaced"
    }
    
    public func isLessThanOneDayUntilExpired(timeInterval: String) -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire(timeInterval: timeInterval)
        return intervalUntilExpiration < 86400
    }
    
    public func isNotCustomLocated() -> Bool {
        return PDStrings.locationNames.contains(self.getLocation()) || getLocation() == "unplaced"
    }
    
    public func isCustomLocated() -> Bool {
        return !isNotCustomLocated()
    }
    
    public func isExpired(timeInterval: String) -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire(timeInterval: timeInterval)
        return self.getdate() != nil && intervalUntilExpiration <= 0
    }
    
    public func notificationString(timeInterval: String) -> String {
        if self.isNotCustomLocated() {
            guard let locationNotificationPart = PDStrings.notificationIntros[getLocation()] else {
                return PDStrings.notificationWithoutLocation + self.expirationDateAsString(timeInterval: timeInterval)
            }
            return locationNotificationPart + self.expirationDateAsString(timeInterval: timeInterval)
        }
            
            // for custom locations
        else {
            let locationNotificationPart = PDStrings.notificationForCustom + self.getLocation() + " " + PDStrings.notificationForCustom_at
            return locationNotificationPart + self.expirationDateAsString(timeInterval: timeInterval)
        }
    }
    
    // MARK: - selectors
    
    public func expirationDate(timeInterval: String) -> Date {
        let hoursLasts = MOEstrogenDelivery.calculateHours(of: timeInterval)
        let calendar = Calendar.current
        guard let dateAdded = self.getdate() else {
            return Date()
        }
        guard let expDate = calendar.date(byAdding: .hour, value: hoursLasts, to: dateAdded) else {
            return Date()
        }
        return expDate
    }
    
    public func determineIntervalToExpire(timeInterval: String) -> TimeInterval {
        if self.getdate() != nil {
            let expirationDate = self.expirationDate(timeInterval: timeInterval)
            let now = Date()
            // for non-expired times, pos exp time
            if expirationDate >= now {
                return DateInterval(start: now, end: expirationDate).duration
            }
            // for expired, neg exp time
            else {
                return -DateInterval(start: expirationDate, end: now).duration
            }
        }
        return TimeInterval()
        
    }
    
    // calculateHours(of) : returns a the integer of number of hours of the inputted expiration interval
    static public func calculateHours(of: String) -> Int {
        var numberOfHours: Int = 84        // half week
        if of == PDStrings.expirationIntervals[1] {
            numberOfHours = 168            // one week
        }
        else if of == PDStrings.expirationIntervals[2] {
            numberOfHours = 336            // two weeks
        }
        return numberOfHours
    }
    
    // MARK: - static
    
    static public func makeDateString(from: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: from)
    }
    
    static public func expiredDate(fromDate: Date) -> Date? {
        let hours: Int = self.calculateHours(of: SettingsDefaultsController.getTimeInterval())
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: hours, to: fromDate) else {
            return nil
        }
        return expDate
        
    }
    
    public static func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }

}
