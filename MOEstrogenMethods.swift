//
//  MOEstrogenMethods.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

    //Description: MOEstrogen is a managed object class that represents either a Patch or an Injection.  MOEstrogen objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the site placed or injected.  MOEstrogen.expirationDate() or MOEstrogen.expirationDateAsString() are useful in the Schedule.

    // This file is an extension of the Patch object to include useful methods.

extension MOEstrogen {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOEstrogen> {
        return NSFetchRequest<MOEstrogen>(entityName: PDStrings.coreDataKeys.estroEntityName)
    }

    //MARK: - Setters
    
   public func setDatePlaced(withDate: Date) {
        datePlaced = withDate
    }
    
    public func setDatePlaced(withString: String) {
        let dateFormatter = DateFormatter()
        datePlaced = dateFormatter.date(from: withString)
    }
    
    public func setLocation(with: String) {
        location = with
    }
    
    // MARK: - Getters
    
    public func getDate() -> Date? {
        return datePlaced
    }
    
    // Return a string indicating non-located instead of nil
    public func getLocation() -> String {
        guard let location = location else {
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
        datePlaced = Date()
    }
    
    public func reset() {
        datePlaced = nil
        location = PDStrings.placeholderStrings.unplaced
    }
    
    // MARK: - Strings
    
    public func string() -> String {
        return getDatePlacedAsString() + "," + getLocation()
    }
    
    public func getDatePlacedAsString() -> String {
        guard let dateAdded = datePlaced else {
            return PDStrings.placeholderStrings.unplaced
        }
        return MOEstrogen.makeDateString(from: dateAdded, useWords: true)
    }
    
    public func expirationDateAsString(timeInterval: String, useWords: Bool) -> String {
        if getDate() == nil {
            return "..."
        }
        let expires = expirationDate(timeInterval: timeInterval)
        return MOEstrogen.makeDateString(from: expires, useWords: useWords)
    }
    
    // MARK: - Booleans
    
    public func hasNoDate() -> Bool {
        return datePlaced == nil
    }
    
    public func isEmpty() -> Bool {
        let loc = location?.lowercased()
        return datePlaced == nil && loc == "unplaced"
    }
    
    public func isCustomLocated() -> Bool {
        let loc = getLocation().lowercased()
        return !PDStrings.siteNames.patchSiteNames.contains(getLocation()) && !PDStrings.siteNames.injectionSiteNames.contains(getLocation()) && loc != "unplaced"
    }
    
    public func isExpired(timeInterval: String) -> Bool {
        if let intervalUntilExpiration = determineIntervalToExpire(timeInterval: timeInterval) {
            return getDate() != nil && intervalUntilExpiration <= 0
        }
        return false
    }
    
    // notificationMessage(timeInterval) : determined the proper message for related notifications.  This depends on the location property.
    public func notificationMessage(timeInterval: String) -> String {
        if !isCustomLocated() {
            guard let siteNotificationPart = PDStrings.notificationStrings.messages.siteToExpiredMessage[getLocation()] else {
                
                // Shouldn't get here
                return expirationDateAsString(timeInterval: timeInterval, useWords: false)
            }
            return siteNotificationPart + expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
            
            // For custom sites
        else {
            let siteNotificationPart = getLocation() + "\n"
            return siteNotificationPart + expirationDateAsString(timeInterval: timeInterval, useWords: false)
        }
    }
    
    // MARK: - Date and time
    
    public func expirationDate(timeInterval: String) -> Date {
        let hoursLasts = MOEstrogen.calculateHours(of: timeInterval)
        let calendar = Calendar.current
        guard let dateAdded = getDate() else {
            return Date()
        }
        guard let expDate = calendar.date(byAdding: .hour, value: hoursLasts, to: dateAdded) else {
            return Date()
        }
        return expDate
    }
    
    public func determineIntervalToExpire(timeInterval: String) -> TimeInterval? {
        if getDate() != nil {
            let expDate = expirationDate(timeInterval: timeInterval)
            let now = Date()
            // For non-expired times, pos exp time
            if expDate >= now {
                return DateInterval(start: now, end: expDate).duration
            }
            // For expired, neg exp time
            else {
                return -DateInterval(start: expDate, end: now).duration
            }
        }
        return nil
        
    }
    
    // calculateHours(of) : returns a the integer of number of hours of the inputted expiration interval
    public static func calculateHours(of: String) -> Int {
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
    
    public static func makeDateString(from: Date, useWords: Bool) -> String {
        let dateFormatter = DateFormatter()
        if useWords, let word = PDDateHelper.dateWord(from: from) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: from)
        }
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: from)
    }
    
    public static func expiredDate(fromDate: Date) -> Date? {
        let hours: Int = calculateHours(of: UserDefaultsController.getTimeInterval())
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: hours, to: fromDate) else {
            return nil
        }
        return expDate
        
    }

}
