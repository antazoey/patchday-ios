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
    
    public var wereChanges: Bool = false
    public var increasedCount: Bool = false
    public var decreasedCount: Bool = false
    public var siteChanged: Bool = false
    public var onlySiteChanged: Bool = false
    public var deliveryMethodChanged: Bool = false
    public var isNew: Bool = false
    public var oldDeliveryCount: Int = 1
    public var indexOfChangedDelivery: Int = -1
    
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
