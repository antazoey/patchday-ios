//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public class EstrogenSchedule {
    
    // Description: EstrogenSchedule is a class for querying the user's managed object array ([MOEstrogen]).  All of the self.supply in the user's current schedule form the EstrogenSchedule.
    
    private var supply: [MOEstrogen]
    public var currentSiteNames: [String]
    public var count: Int
    
    init(estrogens: [MOEstrogen]) {
        self.supply = estrogens
        count = estrogens.count
        self.currentSiteNames = supply.map({
            (value: MOEstrogen) -> String in
            return value.getLocation()
        })
    }
    
    // MARK: - Counters
    
    // count() : Returns the number of non-nil datePlaced MOs in the schedule
    internal func datePlacedCount() -> Int {
        var c: Int = 0
        for estro in supply {
            if !estro.hasNoDate() {
                c += 1
            }
        }
        return c
    }
    
    // MARK: - Oldest MO Related Methods
    
    public func oldestEstro() -> MOEstrogen? {
        // finds oldest MO without using self.supply.sorted(by: <)[0]
        if self.supply.count > 0 {
            var oldest: MOEstrogen = self.supply[0]
            if self.supply.count > 1 {
                for i in 1...(self.supply.count - 1) {
                    let mo = self.supply[i]
                    if let date = mo.getDate(), let oldDate = oldest.getDate() {
                        if date < oldDate {
                            oldest = self.supply[i]
                        }
                    }
                }
            }
            return oldest
        }
        else {
            return nil
        }
    }
    
    public func oldestDate() -> Date? {
        if let oldestEstro = oldestEstro(), let oldestDate = oldestEstro.getDate() {
            return oldestDate
        }
        return nil
    }
    
    public func getOldestDateAsString() -> String? {
        if let oldestEstro = oldestEstro() {
            return oldestEstro.getDatePlacedAsString()
        }
        return nil
    }
    
    public func printSchedule() {
        for estro in self.supply {
            print(estro.getLocation() + ", " + estro.getDatePlacedAsString())
        }
    }
    
    
    // MARK: - Query Bools
    
    public func hasNoDates() -> Bool {
        var allEmptyDates: Bool = true
        for i in 0...(self.supply.count - 1) {
            let estro = self.supply[i]
            if estro.getDate() != nil {
                allEmptyDates = false
                break
            }
        }
        return allEmptyDates
        
    }
    
    public func hasNoLocations() -> Bool {
        var allEmptyLocations: Bool = true
        for i in 0...(self.supply.count - 1){
            let estro = self.supply[i]
            let loc = estro.getLocation().lowercased()
            if loc != "unplaced" {
                allEmptyLocations = false
                break
            }
        }
        return allEmptyLocations
    }
    
    public func isEmpty() -> Bool {
        return hasNoDates() && hasNoLocations()
    }
    
    public func isEmpty(fromThisIndexOnward: Int) -> Bool {
        // returns true if each MO fromThisIndexOnward is empty
        let lastIndex = UserDefaultsController.getQuantityInt() - 1
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: i) {
                    // as soon as a MO is not empty, it will end the search, returning false.2te
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    public func expiredCount(timeInterval: String) -> Int {
        var count = 0
        for estro in supply {
            if estro.isExpired(timeInterval: timeInterval) {
                count += 1
            }
        }
        return count
    }
    
    public func oldestEstroHasNoDateAndIsCustomLocated() -> Bool {
        if let oldestEstro = oldestEstro() {
            return oldestEstro.getDate() == nil && oldestEstro.isCustomLocated()
        }
        return false
    }

}
