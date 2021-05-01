//
//  PillCellActionHandlers.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/19/20.

import Foundation
import PDKit

class PillCellActionHandlers: PillCellActionHandling {

    private let goToDetailsAction: () -> Void
    private let takePillAction: () -> Void
    private let undoTakePillAction: () -> Void

    init(
        goToDetails: @escaping () -> Void,
        takePill: @escaping () -> Void,
        undoTakePill: @escaping () -> Void
    ) {
        self.goToDetailsAction = goToDetails
        self.takePillAction = takePill
        self.undoTakePillAction = undoTakePill
    }

    public func goToDetails() {
        goToDetailsAction()
    }

    public func takePill() {
        takePillAction()
    }

    public func undoTakePill() {
        undoTakePillAction()
    }
}
