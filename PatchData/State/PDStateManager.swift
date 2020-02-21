//
//  PDStateManager.swift
//  PatchData
//
//  Created by Juliya Smith on 11/12/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class PDStateManager: PDStateManaging {
    
    private let state: PDState
    private let defaults: PDSettingsManaging
    private let hormones: HormoneScheduling
    
    init(state: PDState, defaults: PDSettingsManaging, hormones: HormoneScheduling) {
        self.state = state
        self.defaults = defaults
        self.hormones = hormones
    }
    
    public func checkHormoneForStateChanges(at index: Index) -> Bool {
        if let hormone = hormones.at(index) {
            return hormoneHasStateChanges(hormone, at: index, quantity: hormones.count)
        }
        return false
    }

    public func markQuantityAsOld() {
        state.oldQuantity = defaults.quantity.value.rawValue
    }

    public func markSiteAsHavingImageMutation(site: Bodily) {
        state.bodilyMutationsOccurred = true
        for hormoneId in site.hormoneIds {
            state.mutatedHormoneIds.append(hormoneId)
        }
    }

    public func reset() {
        state.hormonalMutationsOccurred = false
        state.theQuantityHasIncreased = false
        state.theQuantityHasDecreased = false
        state.bodilyMutationsOccurred = false
        state.siteChangedButDateDidNotMutated = false
        state.theDeliveryMethodHasMutated = false
        state.mutatedHormoneIds = []
    }

    /// Whether the current state reflects an update-worthy mutation
    private func hormoneHasStateChanges(_ hormone: Hormonal, at index: Index, quantity: Int) -> Bool {
        var hormoneChanged = false
        if index < quantity {
            hormoneChanged = checkHormoneMutationStatus(for: hormone.id, isPlaceholder: hormone.hasSite)
        }
        let isGone = state.theQuantityHasDecreased && index >= quantity
        return state.bodilyMutationsOccurred || hormoneChanged || isGone
    }
    
    private func checkHormoneMutationStatus(for id: UUID, isPlaceholder: Bool) -> Bool {
        state.mutatedHormoneIds.contains(id) && state.bodilyMutationsOccurred && !isPlaceholder
    }
}
