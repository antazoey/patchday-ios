//
//  MOEstrogenDeliveryMethods.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

    //Description: MOEstrogenDelivery is a managed object class that represents either a Patch or an Injection.  MOEstrogenDelivery objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the site placed or injected.  MOEstrogenDelivery.expirationDate() or MOEstrogenDelivery.expirationDateAsString() are useful in the Schedule.

    // This file is an extension of the Patch object to include useful methods.

extension MOEstrogenDelivery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogenDelivery> {
        return NSFetchRequest<MOEstrogenDelivery>(entityName: PDStrings.coreDataKeys.estroEntityName)
    }

    //MARK: - Setters
    
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
    
    // MARK: - Getters
    
    public func getDate() -> Date? {
        return self.datePlaced
    }
    
    // Return a string indicating non-located instead of nil
    public func getLocation() -> String {
        guard let location = self.location else {
            return PDStrings.placeholderStrings.unplaced
        }
        
        // For switching over from legacy location names
        switch location {
        case "Left Stomach":
            return "Left Abdomen"
        case "Right Stomach":
            return "Right Abdomen"
        case "Left Buttock":
            return "Left Glute"
         case "Right Buttock":
            return "Right Glute"
        case "Left Thigh":
            return "Left Quad"
        case "Right Thigh":
            return "Right Quad"
        default:
            return location
        }
    }
    
    // MARK: - Mutators
    
    public func progressToNow() {
        self.datePlaced = Date()
    }
    
    public func reset() {
        self.datePlaced = nil
        self.location = PDStrings.placeholderStrings.unplaced
    }
    
    // MARK: - Strings
    
    public func string() -> String {
        return self.getDatePlacedAsString() + "," + self.getLocation()
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = self.datePlaced else {
            return PDStrings.placeholderStrings.unplaced
        }
        return MOEstrogenDelivery.makeDateString(from: dateAdded, useWords: true)
    }
    
    public func expirationDateAsString(timeInterval: String, useWords: Bool) -> String {
        if self.getDate() == nil {
            return "..."
        }
        let expires = self.expirationDate(timeInterval: timeInterval)
        return MOEstrogenDelivery.makeDateString(from: expires, useWords: useWords)
    }
    
    // MARK: - Booleans
    
    public func hasNoDate() -> Bool {
        return self.datePlaced == nil
    }
    
    public func isEmpty() -> Bool {
        let loc = self.location?.lowercased()
        return self.datePlaced == nil && loc == "unplaced"
    }
    
    public func isCustomLocated() -> Bool {
        let loc = self.getLocation().lowercased()
        return !PDStrings.siteNames.patchSiteNames.contains(self.getLocation()) && !PDStrings.siteNames.injectionSiteNames.contains(self.getLocation()) && loc != "unplaced"
    }
    
    public func isExpired(timeInterval: String) -> Bool {
        if let intervalUntilExpiration = self.determineIntervalToExpire(timeInterval: timeInterval) {
            return self.getDate() != nil && intervalUntilExpiration <= 0
        }
        return false
    }
    
    // notificationMessage(timeInterval) : determined the proper message for related notifications.  This depends on the location property.
    public func notificationMessage(timeInterval: String) -> String {
        if !self.isCustomLocated() {
            guard let siteNotificationPart = PDStrings.notificationStrings.messages.siteToExpiredMessage[getLocation()] else {
                
                // Shouldn't get here
                return self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
            }
            return siteNotificationPart + self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
            
            // For custom sites
        else {
            let siteNotificationPart = self.getLocation() + "\n"
            return siteNotificationPart + self.expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
    }
    
    // MARK: - Date and time
    
    public func expirationDate(timeInterval: String) -> Date {
        let hoursLasts = MOEstrogenDelivery.calculateHours(of: timeInterval)
        let calendar = Calendar.current
        guard let dateAdded = self.getDate() else {
            return Date()
        }
        guard let expDate = calendar.date(byAdding: .hour, value: hoursLasts, to: dateAdded) else {
            return Date()
        }
        return expDate
    }
    
    public func determineIntervalToExpire(timeInterval: String) -> TimeInterval? {
        if self.getDate() != nil {
            let expirationDate = self.expirationDate(timeInterval: timeInterval)
            let now = Date()
            // For non-expired times, pos exp time
            if expirationDate >= now {
                return DateInterval(start: now, end: expirationDate).duration
            }
            // For expired, neg exp time
            else {
                return -DateInterval(start: expirationDate, end: now).duration
            }
        }
        return nil
        
    }
    
    // calculateHours(of) : returns a the integer of number of hours of the inputted expiration interval
    static public func calculateHours(of: String) -> Int {
        var numberOfHours: Int
        switch of {
        case PDStrings.pickerData.expirationIntervals[1]:
            numberOfHours = 168
            break
        case PDStrings.pickerData.expirationIntervals[2]:
            numberOfHours = 336
            break
        default:
            numberOfHours = 84
        }
        return numberOfHours
    }
        
    // MARK: - static
    
    static public func makeDateString(from: Date, useWords: Bool) -> String {
        let dateFormatter = DateFormatter()
        if useWords, let word = MOEstrogenDelivery.dateWord(from: from) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: from)
        }
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: from)
    }
    
    static public func expiredDate(fromDate: Date) -> Date? {
        let hours: Int = self.calculateHours(of: UserDefaultsController.getTimeInterval())
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: hours, to: fromDate) else {
            return nil
        }
        return expDate
        
    }
    
    public static func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if let word = MOEstrogenDelivery.dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - helpers
    
    private static func dateWord(from: Date) -> String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(from) {
            return PDStrings.dayStrings.today
        }
        else if let yesterday = PillDataController.getDate(at: Date(), daysToAdd: -1), calendar.isDate(from, inSameDayAs: yesterday) {
            return PDStrings.dayStrings.yesterday
        }
        else if let tomorrow = PillDataController.getDate(at: Date(), daysToAdd: 1), calendar.isDate(from, inSameDayAs: tomorrow) {
            return PDStrings.dayStrings.tomorrow
        }
        return nil
    }

}
