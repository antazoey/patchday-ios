//
//  PatchDataStateManager.swift
//  PatchData
//
//  Created by Juliya Smith on 11/12/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PatchDataStateManager: PDStateManaging {
    
    private let state: PDState
    private let defaults: UserDefaultsManaging
    private let hormones: HormoneScheduling
    
    init(state: PDState, defaults: UserDefaultsManaging, hormones: HormoneScheduling) {
        self.state = state
        self.defaults = defaults
        self.hormones = hormones
    }
    
    public func stampQuantity() {
        state.oldQuantity = defaults.quantity.value.rawValue
    }
    
    public func hormoneRecentlyMutated(at index: Index) -> Bool {
        if let mone = hormones.at(index) {
            return hormoneHasStateChanges(mone, at: index, quantity: hormones.count)
        }
        return false
    }
    
    public func reset() {
        state.wereHormonalChanges = false
        state.increasedQuantity = false
        state.decreasedQuantity = false
        state.bodilyChanged = false
        state.onlySiteChanged = false
        state.deliveryMethodChanged = false
        state.isCerebral = false
        state.mutatedHormoneIds = [nil]
    }

    /// Prepares the state to represent a proposed site image mutation for a site
    public func markSiteForImageMutation(site: Bodily) {
        state.bodilyChanged = true
        for mone in site.hormones {
            state.mutatedHormoneIds.append(mone.id)
        }
    }

    /// Returns if the current state reflects an update-worthy mutation
    private func hormoneHasStateChanges(_ mone: Hormonal, at index: Index, quantity: Int) -> Bool {
        var moneChanged = false
        state.isCerebral = mone.isCerebral
        if index < quantity {
            moneChanged = checkHormoneMutatationStatus(for: mone.id)
        }
        let isGone = state.decreasedQuantity && index >= quantity

        return (
            state.bodilyChanged
            || moneChanged
            || isGone
        )
    }
    
    private func checkHormoneMutatationStatus(for id: UUID) -> Bool {
        return state.mutatedHormoneIds.contains(id) && state.bodilyChanged && !state.isCerebral
    }
}
