//
//  PillsUITest.swift
//  PatchDayUITests
//

import XCTest

class PillsUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Pills"].tap()
        XCTAssert(app.staticTexts["Pills"].waitForExistence(timeout: 3))
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Pills"].exists)
    }

    func testDefaultPillsExist() throws {
        // After --nuke-storage we get the two DefaultPills: "T-Blocker" and "Progesterone".
        XCTAssert(app.staticTexts["T-Blocker"].waitForExistence(timeout: 3))
        XCTAssert(app.staticTexts["Progesterone"].exists)
    }

    func testInsertNewPill_navigatesToDetail() throws {
        app.buttons["GhostPillCell"].tap()
        XCTAssert(app.staticTexts["New Pill"].waitForExistence(timeout: 3))
    }
}
