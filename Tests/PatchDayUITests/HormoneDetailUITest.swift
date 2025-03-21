//
//  HormoneDetailUITest.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 5/23/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit

class HormoneDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        app.cells["HormoneCell_0"].tap()
        app.buttons["Edit"].tap()
    }

    func openSitePicker() {
        // I don't know why this happens or how I managed
        // to figure it out, but for some reason I have to
        // tap both the stack and text-field in order to open
        // the Site picker automatically.
        app.otherElements["hormoneSiteSelectorStack"].tap()
        app.textFields["selectHormoneSiteTextField"].tap()
    }

    func getCurrentHour() -> String {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now) % 12
        return "\(hour) o’clock"
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Hormone"].waitForExistence(timeout: 2))
    }

    func testSelectSite() throws {
        openSitePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Left Glute")
        XCTAssert(app.staticTexts["Done"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Type"].exists)
        app.buttons["Done"].tap()
        XCTAssertEqual("Left Glute", "\(app.textFields["selectHormoneSiteTextField"].value!)")
    }

    func testOpenSitePicker_whenNavigateAwayAndBack_looksTheSame() throws {
        openSitePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Left Glute")

        // Navigate away and then back
        tabs.buttons["Sites"].tap()
        tabs.buttons["Patches"].tap()

        // Things should still be in the "editting site" state.
        XCTAssertFalse(app.datePickers["hormoneDatePicker"].isEnabled)
        XCTAssertEqual("Left Glute", "\(app.textFields["selectHormoneSiteTextField"].value!)")
        XCTAssert(app.staticTexts["Done"].waitForExistence(timeout: 1))
    }
}
