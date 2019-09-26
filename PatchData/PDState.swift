//
//  EstrogenChangeEffect.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDState: NSObject, PDStateManaging {
    
    override public var description: String {
        return """
               An object that manages the state of the patch data.
               Currently, this only has to do with stuff
               for EstrogenSchedules and PDDefaults.
               The app PatchDay uses this to manage when to animate
               UI features, but it also represents the state
               of the app at the time.
               """
    }
    
    public var wereEstrogenChanges: Bool = false
    public var increasedCount: Bool = false
    public var decreasedCount: Bool = false
    public var siteChanged: Bool = false
    public var onlySiteChanged: Bool = false
    public var deliveryMethodChanged: Bool = false
    public var isNew: Bool = false
    public var oldQuantity: Int = 1
    public var indicesOfChangedDelivery: [Int] = [-1]
    
    public func reset() {
        wereEstrogenChanges = false
        increasedCount = false
        decreasedCount = false
        siteChanged = false
        onlySiteChanged = false
        deliveryMethodChanged = false
        isHormoneless = false
        indicesOfChangedDelivery = []
    }
}
