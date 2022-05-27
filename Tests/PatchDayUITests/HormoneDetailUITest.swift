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

    func openDatePicker() {
        let currentTime = PDDateFormatter.formatTime(Date())
        app.datePickers["hormoneDatePicker"].tap()
        app.datePickers["hormoneDatePicker"].buttons[currentTime].tap()
        _ = app.wait(for: .unknown, timeout: 2.5)
    }

    func getCurrentHour() -> String {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now) % 12
        return "\(hour) o’clock"
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Hormone"].exists)
    }

    func testDatePicker() throws {
        XCTAssert(app.staticTexts["..."].exists)
        openDatePicker()
        let hour = getCurrentHour()
        app.datePickers.pickerWheels[hour].swipeUp()
        app.windows.children(matching: .other).element(boundBy: 2).tap()
        XCTAssertFalse(app.staticTexts["..."].exists)
    }

    func testSelectSite() throws {
        openSitePicker()
        XCTAssert(app.staticTexts["Done"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Type"].exists)
    }

    func testOpenSitePicker_whenNavigateAwayAndBack_looksTheSame() throws {
        openSitePicker()
        tabs.buttons["Sites"].tap()
        tabs.buttons["Patches"].tap()
        XCTAssertFalse(app.datePickers["hormoneDatePicker"].isEnabled)
    }
}
