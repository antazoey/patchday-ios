//
//  EstrogenChangeEffect.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public class PDState: NSObject {

    override public var description: String {
        "DTO for the state of data during a PatchDay session."
    }

    public var wereHormonalChanges = false
    public var increasedQuantity = false
    public var decreasedQuantity = false
    public var bodilyChanged = false
    public var onlySiteChanged = false
    public var deliveryMethodChanged = false
    public var isCerebral = false
    public var oldQuantity = 1
    
    /// List of ids that are affected by mutated data in a session.
    /// Count == 1 when changing hormone attributes, or
    /// Count == n where n = count of site images changed
    public var mutatedHormoneIds: [UUID?] = [nil]
}
