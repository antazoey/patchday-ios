//
//  PillCellActionAlertHandlersTests.swift
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

class PillCellActionAlertHandlersTests: XCTestCase {
    func testGoToDetails_callsExpectedHookFromInit() {
        var navCalled = false
        var takeCalled = false
        var undoCalled = false
        let nav = { navCalled = true }
        let take = { takeCalled = true }
        let undo = { undoCalled = true }
        let handlers = PillCellActionHandlers(
            goToDetails: nav, takePill: take, undoTakePill: undo
        )
        handlers.goToDetails()
        XCTAssertTrue(navCalled)
        XCTAssertFalse(takeCalled)
        XCTAssertFalse(undoCalled)
    }

    func testTakePill_callsExpectedHookFromInit() {
        var navCalled = false
        var takeCalled = false
        var undoCalled = false
        let nav = { navCalled = true }
        let take = { takeCalled = true }
        let undo = { undoCalled = true }
        let handlers = PillCellActionHandlers(
            goToDetails: nav, takePill: take, undoTakePill: undo
        )
        handlers.takePill()
        XCTAssertFalse(navCalled)
        XCTAssertTrue(takeCalled)
        XCTAssertFalse(undoCalled)
    }

    func testUndoTakePill_callsExpectedHookFromInit() {
        var navCalled = false
        var takeCalled = false
        var undoCalled = false
        let nav = { navCalled = true }
        let take = { takeCalled = true }
        let undo = { undoCalled = true }
        let handlers = PillCellActionHandlers(
            goToDetails: nav, takePill: take, undoTakePill: undo
        )
        handlers.undoTakePill()
        XCTAssertFalse(navCalled)
        XCTAssertFalse(takeCalled)
        XCTAssertTrue(undoCalled)
    }
}
