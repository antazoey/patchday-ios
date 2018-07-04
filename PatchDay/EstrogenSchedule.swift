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
            if let site = value.getSite(), let name = site.getName() {
                return name
            }
            else {
                return ""
            }
        }).filter() {
            $0 != ""
        }
    }
    
    // MARK: - Counters
    
    // Returns the number of non-nil dates in given estrogens.
    internal func datePlacedCount() -> Int {
        return supply.reduce(0, {
            count, estro in
            let c = !(estro.date == nil) ? 1 : 0
            return c
        })
    }
    
    // MARK: - Oldest MO Related Methods
    
    public func oldestEstro() -> MOEstrogen? {
        if supply.count > 0 {
            return supply.reduce(supply[0], {
                oldest, estro in
                if let date = estro.getDate(), let oldDate = oldest.getDate() {
                    if (date as Date) < (oldDate as Date) {
                        return estro
                    }
                }
                return oldest
            })
        }
        return nil
    }
    
    public func oldestDate() -> Date? {
        if let oldestEstro = oldestEstro(), let oldestDate = oldestEstro.getDate() {
            return oldestDate as Date
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
        for estro in supply {
            if let site = estro.getSite(), let siteName = site.getName() {
                print(siteName + ", " + estro.getDatePlacedAsString())
            }
        }
    }
    
    
    // MARK: - Query Bools
    
    public func hasNoDates() -> Bool {
        return (supply.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    public func hasNoLocations() -> Bool {
        return (supply.filter() {
            $0.getSite() != nil
        }).count == 0
    }
    
    public func isEmpty() -> Bool {
        return hasNoDates() && hasNoLocations()
    }
    
    public func isEmpty(fromThisIndexOnward: Int, lastIndex: Int) -> Bool {
        // returns true if each MOEstrogen fromThisIndexOnward is empty
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if i >= 0 && i < supply.count {
                    let estro = supply[i]
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // Returns how many expired estrogens there are in the given estrogens.
    public func expiredCount(_ intervalStr: String) -> Int {
        return supply.reduce(0, {
            count, estro in
            let c = (estro.isExpired(intervalStr)) ? 1 : 0
            return c
        })
    }
    
    public func oldestEstroHasNoDateAndIsCustomLocated() -> Bool {
        if let oldestEstro = oldestEstro() {
            return oldestEstro.getDate() == nil && oldestEstro.isCustomLocated()
        }
        return false
    }

}
