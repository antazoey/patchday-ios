//
//  PillDetailUITest.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 6/2/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit

class PillDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.tabBars["Tab Bar"].buttons["Pills"].tap()
        app.tables.staticTexts["T-Blocker"].tap()
        app.buttons["Edit"].tap()
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Pill"].exists)
    }
}
