//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public class EstrogenSchedule {
    
    // Description: EstrogenSchedule is a class for querying the user's managed object array ([MOEstrogen]).  All of the supply in the user's current schedule form the EstrogenSchedule.
    
    private var supply: [MOEstrogen]
    public var currentSiteNames: [String]
    public var count: Int
    
    init(estrogens: [MOEstrogen]) {
        self.supply = estrogens
        self.count = estrogens.count
        self.currentSiteNames = supply.map({
            (value: MOEstrogen) -> String in
            return value.getLocation()
        })
    }
    
    // MARK: - Counters
    
    // Returns the number of non-nil dates in given estrogens.
    internal func datePlacedCount(estrogens: [MOEstrogen]) -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = (!estro.hasNoDate()) ? 1 : 0
            return c
        })
    }
    
    // MARK: - Oldest MO Related Methods
    
    public func oldestEstro(estrogens: [MOEstrogen]) -> MOEstrogen? {
        if estrogens.count > 0 {
            return estrogens.reduce(estrogens[0], {
                oldest, estro in
                if let date = estro.getDate(), let oldDate = oldest.getDate() {
                    if date < oldDate {
                        return estro
                    }
                }
                return oldest
            })
        }
        return nil
    }
    
    public func oldestDate(estrogens: [MOEstrogen]) -> Date? {
        if let oldestEstro = oldestEstro(estrogens: estrogens), let oldestDate = oldestEstro.getDate() {
            return oldestDate
        }
        return nil
    }
    
    public func getOldestDateAsString(estrogens: [MOEstrogen]) -> String? {
        if let oldestEstro = oldestEstro(estrogens: estrogens) {
            return oldestEstro.getDatePlacedAsString()
        }
        return nil
    }
    
    public func printSchedule() {
        for estro in supply {
            print(estro.getLocation() + ", " + estro.getDatePlacedAsString())
        }
    }
    
    
    // MARK: - Query Bools
    
    public func hasNoDates(estrogens: [MOEstrogen]) -> Bool {
        return (estrogens.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    public func hasNoLocations(estrogens: [MOEstrogen]) -> Bool {
        return (estrogens.filter() {
            $0.getLocation() != "unplaced"
        }).count == 0
    }
    
    public func isEmpty(estrogens: [MOEstrogen]) -> Bool {
        return hasNoDates(estrogens: estrogens) && hasNoLocations(estrogens: estrogens)
    }
    
    public func isEmpty(inside estrogens: [MOEstrogen], fromThisIndexOnward: Int, lastIndex: Int) -> Bool {
        // returns true if each MOEstrogen fromThisIndexOnward is empty
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: i) {
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // Returns how many expired estrogens there are in the given estrogens.
    public func expiredCount(estrogens: [MOEstrogen], timeInterval: String) -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = (estro.isExpired(timeInterval: timeInterval)) ? 1 : 0
            return c
        })
    }
    
    public func oldestEstroHasNoDateAndIsCustomLocated(estrogens: [MOEstrogen]) -> Bool {
        if let oldestEstro = oldestEstro(estrogens: estrogens) {
            return oldestEstro.getDate() == nil && oldestEstro.isCustomLocated()
        }
        return false
    }

}
