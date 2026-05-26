//
//  SettingsUITest.swift
//  PatchDayUITests
//

import XCTest

class SettingsUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.buttons["settingsGearButton"].tap()
        XCTAssert(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }

    func testTitle() throws {
        XCTAssert(app.navigationBars["Settings"].exists)
    }
}
