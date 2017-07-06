//
//  Patch+CoreDataProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

extension Patch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patch> {
        return NSFetchRequest<Patch>(entityName: PatchDayStrings.entityName)
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
    
    public func getDatePlaced() -> Date? {
        return self.datePlaced
    }
    
    public func getLocation() -> String {
        guard let location = self.location else {
            return PatchDayStrings.unplaced_string
        }
        return location
    }
    
    // MARK: - mutators
    
    public func progressToNow() {
        self.datePlaced = Date()
    }
    
    public func reset() {
        self.datePlaced = nil
        self.location = PatchDayStrings.unplaced_string
    }
    
    // MARK: - strings
    
    public func string() -> String {
        return self.getDatePlacedAsString(dateStyle: .medium) + "," + self.getLocation()
    }
    
    public func getDatePlacedAsString(dateStyle: DateFormatter.Style) -> String {
        guard let dateAdded = self.datePlaced else {
            return PatchDayStrings.unplaced_string
        }
        return Patch.makeDateString(from: dateAdded)
    }
    
    public func expirationDateAsString() -> String {
        if self.getDatePlaced() == nil {
            return PatchDayStrings.hasNoDate
        }
        let expires = self.expirationDate()
        return Patch.makeDateString(from: expires)
    }
    
    public func dayOfWeekFromDate(date: Date) -> Int {
        let calendar = Calendar(identifier: Locale.current.calendar.identifier)
        return calendar.component(.weekday, from: date)
    }
    
    // MARK: - booleans
    
    public func isEmpty() -> Bool {
        return self.location == nil || self.location == PatchDayStrings.unplaced_string
    }
    
    public func isLessThanOneDayUntilExpired() -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire()
        return intervalUntilExpiration < 86400
    }
    
    public func isNotCustomLocated() -> Bool {
        return PatchDayStrings.patchLocationNames.contains(self.getLocation()) || getLocation() == "unplaced"
    }
    
    public func isCustomLocated() -> Bool {
        return !isNotCustomLocated()
    }
    
    public func isExpired() -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire()
        return self.getDatePlaced() != nil && intervalUntilExpiration <= 0
    }
    
    // MARK: - selectors
    
    public func expirationDate() -> Date {
        let numberOfHoursPatchLasts = Patch.calculateHoursOfPatchDuration()
        let calendar = Calendar.current
        guard let dateAdded = self.getDatePlaced() else {
            return Date()
        }
        guard let expDate = calendar.date(byAdding: .hour, value: numberOfHoursPatchLasts, to: dateAdded) else {
            return Date()
        }
        return expDate
    }
    
    public func determineIntervalToExpire() -> TimeInterval {
        if self.getDatePlaced() != nil {
            let expirationDate = self.expirationDate()
            let now = Date()
            // for non-expired patches, it's time to expire is positive
            if expirationDate >= now {
                return DateInterval(start: now, end: expirationDate).duration
            }
            // for expired patches, it's time to expire is negative
            else {
                return -DateInterval(start: expirationDate, end: now).duration
            }
        }
        return TimeInterval()
        
    }
    
    static func calculateHoursOfPatchDuration() -> Int {
        let patchInterval = SettingsController.getExpirationInterval()
        // defaults as half week
        var numberOfHours = 84
        // full week
        if patchInterval == PatchDayStrings.expirationIntervals[1] {
            numberOfHours = 168
        }
        return numberOfHours
    }
    
    // MARK: - static
    
    static func makeDateString(from: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: from)
    }
    
    static func expiredDate(fromDate: Date) -> Date {
        let numberOfHoursPatchLasts = calculateHoursOfPatchDuration()
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: numberOfHoursPatchLasts, to: fromDate) else {
            return Date()
        }
        return expDate
        
    }
  
}
