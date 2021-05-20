//
//  PillCellActionAlertTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/1/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class PillCellActionAlertTests: XCTestCase {
    func testPresent_succeeds() {
        let handlers = PillCellActionHandlers(
            goToDetails: {}, takePill: {}, undoTakePill: {}
        )
        let alert = PillCellActionAlert(pill: MockPill(), handlers: handlers)
        alert.present()
    }
}
