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

    func changeSchedule(to option: String) {
        openSchedulePicker()
        XCTAssert(app.pickerWheels.element.waitForExistence(timeout: 5))
        app.pickerWheels.element.adjust(toPickerWheelValue: option)
        app.staticTexts["Done"].tap()
    }

    func navigateAwayAndBack() {
        tabs.buttons["Sites"].tap()
        tabs.buttons["Pills"].tap()
    }

    // MARK: Tests

    func testTitle() throws {
        XCTAssert(app.staticTexts["Edit Pill"].exists)
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
        navigateAwayAndBack()
        app.staticTexts["Done"].tap()
        XCTAssertEqual("Prolactin", "\(app.textFields["pillNameTextField"].value!)")
    }

    func testSelectSchedule() throws {
        changeSchedule(to: "Every Other Day")
        XCTAssert(app.staticTexts["Every Other Day"].exists)
    }

    func testSelectSchedule_whenFirstXDays_showsAdditionalControls() throws {
        changeSchedule(to: "First X Days of Month")
        XCTAssert(app.staticTexts["First \"X\" days of the month:"].exists)
    }

    func testSelectSchedule_whenLastXDays_showsAdditionalControls() throws {
        changeSchedule(to: "Last X Days of Month")
        XCTAssert(app.staticTexts["Last \"X\" days of the month:"].exists)
    }

    func testSelectSchedule_whenXDaysOnXDaysOff_showsAdditionalControls() throws {
        changeSchedule(to: "X Days On, X Days Off")
        XCTAssert(app.staticTexts["Days on:"].exists)
        XCTAssert(app.staticTexts["Days off:"].exists)
        XCTAssert(app.staticTexts["Current position: 1 of 12 (on)"].exists)
    }

    func testSelectSchedule_whenNavigateAwayAndBack_canStillCloseAndSave() throws {
        // There was a bug where the target would get replaced when navigating back.
        openSchedulePicker()
        app.pickerWheels.element.adjust(toPickerWheelValue: "X Days On, X Days Off")
        navigateAwayAndBack()
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["Current position: 1 of 12 (on)"].exists)
    }

    func testSetXDaysOne() throws {
        changeSchedule(to: "X Days On, X Days Off")
        app.buttons["pillDaysOneScheduleButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "7")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["7"].exists)
    }

    func testSetXDaysOne_whenNavigatingAwayAndBack_canStillCloseAndSave() throws {
        changeSchedule(to: "X Days On, X Days Off")
        app.buttons["pillDaysOneScheduleButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "7")
        navigateAwayAndBack()
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["7"].exists)
    }

    func testSetXDaysTwo() throws {
        changeSchedule(to: "X Days On, X Days Off")
        app.buttons["pillDaysTwoScheduleButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "6")
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["6"].exists)
    }

    func testSetXDaysTwo_whenNavigatingAwayAndBack_canStillCloseAndSave() throws {
        changeSchedule(to: "X Days On, X Days Off")
        app.buttons["pillDaysTwoScheduleButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "6")
        navigateAwayAndBack()
        app.staticTexts["Done"].tap()
        XCTAssert(app.staticTexts["6"].exists)
    }
}
