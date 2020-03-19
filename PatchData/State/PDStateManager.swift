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
    private let settings: PDSettingsManaging
    private let hormones: HormoneScheduling
    private lazy var log = PDLog<PDStateManager>()
    
    init(state: PDState, settings: PDSettingsManaging, hormones: HormoneScheduling) {
        self.state = state
        self.settings = settings
        self.hormones = hormones
    }
    
    public func checkHormoneForStateChanges(at index: Index) -> Bool {
        guard let hormone = hormones.at(index) else { return false }
        let hasChanges = hormoneHasStateChanges(hormone, at: index, quantity: hormones.count)
        log.info("Hormone at index \(index) change status: \(hasChanges)")
        return hasChanges
    }

    public func markQuantityAsOld() {
        state.oldQuantity = settings.quantity.value.rawValue
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
        state.bodilyMutationsOccurred
            || hormoneChangedFromRemove(index, quantity)
            || hormoneChangedFromEdit(hormone.id, hormone.hasSite, index, quantity)
    }
    
    private func hormoneChangedFromEdit(
        _ id: UUID,
        _ isPlaceholder: Bool,
        _ index: Int,
        _ quantity: Int
    ) -> Bool {
        state.mutatedHormoneIds.contains(id)
            && state.bodilyMutationsOccurred
            && !isPlaceholder
            && index < quantity
    }
    
    private func hormoneChangedFromRemove(_ index: Index, _ quantity: Int) -> Bool {
        state.theQuantityHasDecreased && index >= quantity
    }
}
 
