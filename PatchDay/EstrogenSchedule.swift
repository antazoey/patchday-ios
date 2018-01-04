//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

public class EstrogenSchedule {
    
    // Description: EstrogenSchedule is a class for querying the user's managed object array ([MOEstrogenDelivery]).  All of the self.supply in the user's current schedule form the EstrogenSchedule.  The EstrogenSchedule is used to suggest a location, as part of the "Suggest Location Functionality" mentioned on the SettingsVC.  It also finds the oldest MO in the schedule, which is important when changing an MO in the ScheduleController.
    
    private var supply: [MOEstrogenDelivery]
    
    init(estrogens: [MOEstrogenDelivery]) {
        self.supply = estrogens
    }
    
    // MARK: - Suggest Location Functionality
    
    // how to access the Suggest Location Algorithm
    internal func suggestLocation(scheduleIndex: Int) -> String {
        return SLF.suggest(scheduleIndex: scheduleIndex, generalLocations: makeArrayOfLocations())
    }
    
    internal func makeArrayOfLocations() -> [String] {
        var locationArray: [String] = []
        for i in 0...(UserDefaultsController.getQuantityInt() - 1) {
            if i < self.supply.count {
                let mo = self.supply[i]
                locationArray.append(mo.getLocation())
            }
        }
        return locationArray
    }
    
    // MARK: - Oldest MO Related Methods
    
    public func oldestMO() -> MOEstrogenDelivery? {
        // finds oldest MO without using self.supply.sorted(by: <)[0]
        if self.supply.count > 0 {
            var oldest: MOEstrogenDelivery = self.supply[0]
            if self.supply.count > 1 {
                for i in 1...(self.supply.count - 1) {
                    let mo = self.supply[i]
                    if let date = mo.getdate(), let oldDate = oldest.getdate() {
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
    
    public func oldestdate() -> Date? {
        if let oldestMO = oldestMO(), let oldestdate = oldestMO.getdate() {
            return oldestdate
        }
        return nil
    }
    
    public func getOldestdateAsString() -> String? {
        if let oldestMO = oldestMO() {
            return oldestMO.getDatePlacedAsString()
        }
        return nil
    }
    
    public func printSchedule() {
        for mo in self.supply {
            print(mo.getLocation() + ", " + mo.getDatePlacedAsString())
        }
    }
    
    
    // MARK: - Query Bools
    
    public func scheduleHasNoDates() -> Bool {
        var allEmptyDates: Bool = true
        for i in 0...(self.supply.count - 1) {
            let mo = self.supply[i]
            if mo.getdate() != nil {
                allEmptyDates = false
                break
            }
        }
        return allEmptyDates
        
    }
    
    public func scheduleHasNoLocations() -> Bool {
        var allEmptyLocations: Bool = true
        for i in 0...(self.supply.count - 1){
            let mo = self.supply[i]
            if mo.getLocation() != "unplaced" {
                allEmptyLocations = false
                break
            }
        }
        return allEmptyLocations
    }
    
    public func scheduleIsEmpty() -> Bool {
        return scheduleHasNoDates() && scheduleHasNoLocations()
    }
    
    public func scheduleIsEmpty(fromThisIndexOnward: Int) -> Bool {
        // returns true if each MO fromThisIndexOnward is empty
        let lastIndex = UserDefaultsController.getQuantityInt() - 1
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if let mo = ScheduleController.coreData.getMO(forIndex: i) {
                    // as soon as a MO is not empty, it will end the search, returning false.2te
                    if !mo.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    public func oldestMOInScheduleHasNoDateAndIsCustomLocated() -> Bool {
        if let oldestMO = oldestMO() {
            return oldestMO.getdate() == nil && oldestMO.isCustomLocated()
        }
        return false
    }
    
    
}
