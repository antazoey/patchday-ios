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

    func openPillPicker() {
        app.otherElements["pillNameStack"].tap()
        app.buttons["selectPillButton"].tap()
        _ = app.wait(for: .unknown, timeout: 1)
    }

    func openSchedulePicker() {
        app.otherElements["pillScheduleStack"].tap()
        app.buttons["pillScheduleButton"].tap()
        _ = app.wait(for: .unknown, timeout: 1)
    }

    func testSelectName() throws {
        openPillPicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Prolactin")
        app.staticTexts["Done"].tap()
        XCTAssertEqual("Prolactin", "\(app.textFields["pillNameTextField"].value!)")
    }

    func testSelectName_whenNavigateAwayAndBack_canStillCloseAndSave() throws {
        // There was a bug where the target would get replaced when navigating back.
        openPillPicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Prolactin")
        tabs.buttons["Sites"].tap()
        tabs.buttons["Pills"].tap()
        app.staticTexts["Done"].tap()
        XCTAssertEqual("Prolactin", "\(app.textFields["pillNameTextField"].value!)")
    }

    func testSelectSchedule() throws {
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Every Other Day")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["Every Other Day"].exists)
    }

    func testSelectSchedule_whenFirstXDays_showsAdditionalControls() {
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "First X Days of Month")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["First \"X\" days of the month:"].exists)
    }

    func testSelectSchedule_whenLastXDays_showsAdditionalControls() {
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Last X Days of Month")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["Last \"X\" days of the month:"].exists)
    }

    func testSelectSchedule_whenXDaysOnXDaysOff_showsAdditionalControls() {
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "X Days On, X Days Off")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["Days on:"].exists)
        XCTAssert(app.staticTexts["Days off:"].exists)
        XCTAssert(app.staticTexts["Current position: 1 of 12 (on)"].exists)
    }

    func testSelectSchedule_whenNavigateAwayAndBack_canStillCloseAndSave() throws {
        // There was a bug where the target would get replaced when navigating back.
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "X Days On, X Days Off")
        tabs.buttons["Sites"].tap()
        tabs.buttons["Pills"].tap()
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["Current position: 1 of 12 (on)"].exists)
    }
}
