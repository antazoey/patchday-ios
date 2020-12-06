//
//  PillCellActionHandlers.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/19/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillCellActionHandlers: PillCellActionHandling {

    private let goToDetailsAction: () -> Void
    private let takePillAction: () -> Void

    init(goToDetails: @escaping () -> Void, takePill: @escaping () -> Void) {
        self.goToDetailsAction = goToDetails
        self.takePillAction = takePill
    }

    public func goToDetails() {
        goToDetailsAction()
    }

    public func takePill() {
        takePillAction()
    }
}
