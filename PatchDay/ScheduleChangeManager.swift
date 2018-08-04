//
//  EstrogenChangeEffect.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public class ScheduleChangeManager: NSObject {
    
    override public var description: String {
        return "An object that manages changes in a schedule."
    }
    
    var wereChanges: Bool = false
    var increasedCount: Bool = false
    var decreasedCount: Bool = false
    var siteChanged: Bool = false
    var onlySiteChanged: Bool = false
    var deliveryMethodChanged: Bool = false
    var isNew: Bool = false
    var oldDeliveryCount: Int = 1
    var indexOfChangedDelivery: Int = -1
    
    public func reset() {
        wereChanges = false
        increasedCount = false
        decreasedCount = false
        siteChanged = false
        onlySiteChanged = false
        deliveryMethodChanged = false
        isNew = false
    }
    
    
}
