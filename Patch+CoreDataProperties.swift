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
        var location = ""
        if self.location != nil {
            location = self.location!
        }
        else {
            location = PatchDayStrings.unplaced_string
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
        return self.getDatePlacedAsString() + "," + self.getLocation()
    }
    
    public func getDatePlacedAsString() -> String {
        var dateString = ""
        if self.datePlaced != nil {
            dateString = Patch.makeDateString(from: self.datePlaced!)
        }
        else {
            dateString = PatchDayStrings.unplaced_string
        }
        return dateString
    }
    
    public func expirationDateAsString() -> String {
        var expirationAsString = ""
        if self.getDatePlaced() != nil {
            var expires = Date()
            expires = self.expirationDate()
            expirationAsString = Patch.makeDateString(from: expires)
        }
        else {
            expirationAsString = PatchDayStrings.hasNoDate
        }
        return expirationAsString
    }
    
    // MARK: - booleans
    
    public func isEmpty() -> Bool {
        var emptiness = false
        if self.location == nil || self.location == PatchDayStrings.unplaced_string {
            emptiness = true
        }
        return emptiness
    }
    
    public func isLessThanOneDayUntilExpired() -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire()
        var isLessThanADayAway: Bool = false
        if intervalUntilExpiration != nil && intervalUntilExpiration! < 86400 {
            isLessThanADayAway = true
        }
        return isLessThanADayAway
    }
    
    public func isNotCustomLocated() -> Bool {
        return PatchDayStrings.patchLocationNames.contains(self.getLocation())
    }
    
    public func isCustomLocated() -> Bool {
        return !isNotCustomLocated()
    }
    
    public func isExpired() -> Bool {
        let intervalUntilExpiration = self.determineIntervalToExpire()
        var expired: Bool = false
        if self.getDatePlaced() != nil && intervalUntilExpiration != nil && intervalUntilExpiration! <= 0 {
            expired = true
        }
        return expired
    }
    
    // MARK: - selectors
    
    public func expirationDate() -> Date {
        let numberOfHoursPatchLasts = calculateHoursOfPatchDuration()
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .hour, value: numberOfHoursPatchLasts, to: self.getDatePlaced()!)
        return expirationDate!
    }
    
    public func determineIntervalToExpire() -> TimeInterval? {
        var interval = TimeInterval()
        if self.getDatePlaced() != nil {
            let expirationDate = self.expirationDate()
            let now = Date()
            if expirationDate > now {
                interval = DateInterval(start: now, end: expirationDate).duration
            }
            else {
                interval = -DateInterval(start: expirationDate, end: now).duration
            }
        }
        return interval
        
    }
    
    // MARK: - private
    
    private func calculateHoursOfPatchDuration() -> Int {
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
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: from)
    }
  
}
