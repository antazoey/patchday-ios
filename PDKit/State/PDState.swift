//
//  EstrogenChangeEffect.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public class PDState: NSObject, PDStateManaging {

    override public var description: String {
        """
        Manages the state of data during a PatchDay session.
        """
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

    public func reset() {
        wereHormonalChanges = false
        increasedQuantity = false
        decreasedQuantity = false
        bodilyChanged = false
        onlySiteChanged = false
        deliveryMethodChanged = false
        isCerebral = false
        mutatedHormoneIds = [nil]
    }

    /// Prepares the state to represent a proposed site image mutation for a site
    public func markSiteForImageMutation(site: Bodily) {
        bodilyChanged = true
        for mone in site.hormones {
            mutatedHormoneIds.append(mone.id)
        }
    }

    /// Returns if the current state reflects an update-worthy mutation
    public func hormoneHasStateChanges(_ mone: Hormonal, at index: Index, quantity: Int) -> Bool {
        var moneChanged = false
        isCerebral = mone.isCerebral
        if index < quantity {
            moneChanged = checkHormoneMutatationStatus(for: mone.id)
        }
        let isGone = decreasedQuantity && index >= quantity

        return (
            bodilyChanged
            || moneChanged
            || isGone
        )
    }
    
    private func checkHormoneMutatationStatus(for id: UUID) -> Bool {
        if mutatedHormoneIds.contains(id) {
            return bodilyChanged && !isCerebral
        }
        return false
    }
}
