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
        if let hormone = hormones.at(index) {
            return hormoneHasStateChanges(hormone, at: index, quantity: hormones.count)
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
        for hormone in site.hormones {
            state.mutatedHormoneIds.append(hormone.id)
        }
    }

    /// Whether the current state reflects an update-worthy mutation
    private func hormoneHasStateChanges(_ hormone: Hormonal, at index: Index, quantity: Int) -> Bool {
        var hormoneChanged = false
        state.isCerebral = hormone.isCerebral
        if index < quantity {
            hormoneChanged = checkHormoneMutationStatus(for: hormone.id)
        }
        let isGone = state.decreasedQuantity && index >= quantity

        return (
            state.bodilyChanged
            || hormoneChanged
            || isGone
        )
    }
    
    private func checkHormoneMutationStatus(for id: UUID) -> Bool {
        state.mutatedHormoneIds.contains(id) && state.bodilyChanged && !state.isCerebral
    }
}