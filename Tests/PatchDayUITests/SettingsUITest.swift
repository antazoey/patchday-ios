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

    func testSetQuantity() throws {
        app.buttons["settingsQuantityButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "4")
        app.buttons["Save"].tap()
        XCTAssertEqual("4", app.buttons["settingsQuantityButton"].label)
    }

    func testSetQuantity_whenNavigateAwayAndBack() {
        app.buttons["settingsQuantityButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "4")

        app.buttons["Pills"].tap()
        app.buttons["Patches"].tap()

        app.buttons["Save"].tap()
        XCTAssertEqual("4", app.buttons["settingsQuantityButton"].label)
    }

    func testSetNotificationsMinutesBefore() {
        app.sliders.element.adjust(toNormalizedSliderPosition: 0.75)
        XCTAssert(app.staticTexts["93"].exists || app.staticTexts["94"].exists)
    }
}
