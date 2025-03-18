//
//  SitesUITests.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 5/22/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit

class SitesUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
    }

    var table: XCUIElementQuery {
        app.tables.matching(.table, identifier: "sitesTableView")
    }

    func changeDeliveryMethod(_ deliveryMethod: String) {
        tabs.buttons["Patches"].tap()
        app.buttons["settingsGearButton"].tap()
        app.buttons["deliveryMethodButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: deliveryMethod)
        app.buttons["deliveryMethodButton"].tap()  // Save
        tabs.buttons["Sites"].tap()
    }

    func addSite(_ index: Int) {
        app.buttons["insertNewSiteButton"].tap()
        XCTAssert(app.buttons["Type"].waitForExistence(timeout: 2))

        app.buttons["Type"].tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: "New Site".count)
        app.textFields.element.typeText("\(deleteString)TEST_SITE_\(index)")
        app.buttons["Save"].tap()
        _ = app.wait(for: .unknown, timeout: 2.5)
    }

    func deleteSiteFromSwipe(_ index: Int) {
        cellAt(index).swipeLeft()
        cellAt(index).swipeLeft()
        _ = app.wait(for: .unknown, timeout: 1)
    }

    func tapEdit() {
        XCTAssert(app.buttons["Edit"].waitForExistence(timeout: 4))
        app.buttons["Edit"].tap()
        XCTAssert(app.buttons["Reset"].waitForExistence(timeout: 4))
    }

    func deleteSiteFromEdit(_ siteName: String) {
        // NOTE: Should be editting if you are calling this method.
        XCTAssert(app.buttons["Remove \(siteName)"].waitForExistence(timeout: 2))
        app.buttons["Remove \(siteName)"].tap()
        app.buttons["Delete"].tap()
    }

    func cellAt(_ index: Int) -> XCUIElement {
        app.cells["SiteCell_\(index)"]
    }

    func testTitle_isSites() throws {
        XCTAssert(app.staticTexts["Sites"].exists)
    }

    func testCellCount_whenPatches() throws {
        XCTAssertEqual(4, table.cells.count)
    }

    func testCellCount_whenInjections() throws {
        changeDeliveryMethod("Injections")
        XCTAssertEqual(6, table.cells.count)
    }

    func testNewSite_addsCell() throws {
        let index = table.cells.count
        addSite(index)
        XCTAssertEqual(index + 1, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        XCTAssert(app.staticTexts["4."].exists)
        XCTAssert(app.staticTexts["5."].exists)
        XCTAssertFalse(app.staticTexts["6."].exists)
    }

    func testDeleteCellFromSwipe_deletesCell() throws {
        deleteSiteFromSwipe(1)
        XCTAssertEqual(3, table.cells.count)

        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)

        deleteSiteFromSwipe(0)
        XCTAssertEqual(2, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
    }

    func testDeleteFromEdittingButtons() throws {
        tapEdit()
        deleteSiteFromEdit("Left Glute")
        deleteSiteFromEdit("Right Abdomen")
        app.buttons["Done"].tap()

        XCTAssertEqual(2, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
    }

    func testAddsAndDeletes() throws {
        var count = table.cells.count
        XCTAssertLessThanOrEqual(2, count)  // Test requires at least 2.

        // Delete two cells.
        deleteSiteFromSwipe(count - 1)
        deleteSiteFromSwipe(0)
        count -= 2

        XCTAssertEqual(count, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)

        // Add a site.
        addSite(1)
        count += 1

        XCTAssertEqual(count, table.cells.count)
        for idx in 1...count {
            XCTAssert(app.staticTexts["\(idx)."].waitForExistence(timeout: 4))
        }
    }

    func testReset() throws {
        deleteSiteFromSwipe(2)
        deleteSiteFromSwipe(0)
        addSite(1)
        app.buttons["Edit"].tap()
        app.buttons["Reset"].tap()

        XCTAssertEqual(4, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        XCTAssert(app.staticTexts["4."].exists)
    }

    func testResetAfterDelete() throws {
        tapEdit()
        deleteSiteFromEdit("Left Glute")
        app.buttons["Reset"].tap()
        XCTAssertEqual(4, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        XCTAssert(app.staticTexts["4."].exists)
    }
}
