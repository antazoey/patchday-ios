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
    public var count: Int
    
    init(estrogens: [MOEstrogen]) {
        self.supply = estrogens
        self.count = estrogens.count
    }
    
    // MARK: - Counters

    
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

    public func oldestEstroHasNoDateAndIsCustomLocated() -> Bool {
        if let oldestEstro = oldestEstro() {
            return oldestEstro.getDate() == nil && oldestEstro.isCustomLocated()
        }
        return false
    }

}
