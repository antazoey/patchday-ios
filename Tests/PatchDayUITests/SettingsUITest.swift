//
//  SettingsUITest.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 6/2/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit

class SettingsUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.navigationBars["Patches"].buttons["settingsGearButton"].tap()
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Settings"].exists)
    }
}
