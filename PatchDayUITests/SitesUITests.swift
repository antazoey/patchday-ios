//
//  PatchDayUITests.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 5/22/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit

class SitesUITests: XCTestCase {

    var app: XCUIApplication!
    var tabs: XCUIElementQuery!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("--nuke-storage")
        app.launch()
        addUIInterruptionMonitor(withDescription: "Disclaimer") {
          (alert) -> Bool in
          alert.buttons["Dismiss"].tap()
          return true
        }
        tabs = app.tabBars

        // Start on Sites view
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
        app.buttons["Type"].tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: "New Site".count)
        app.textFields.element.typeText("\(deleteString)TEST_SITE_\(index)")
        app.buttons["Save"].tap()
        _ = app.wait(for: .unknown, timeout: 2.5)
    }
    
    func deleteSite(_ index: Int) {
        cellAt(index).swipeLeft()
        _ = app.wait(for: .unknown, timeout: 1)
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
    
    func testNewSite_hasExpectedTitle() throws {
        app.buttons["insertNewSiteButton"].tap()
        XCTAssert(app.staticTexts["New Site"].exists)
    }
    
    func testNewSite_addsCell() throws {
        addSite(4)
        XCTAssertEqual(5, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        XCTAssert(app.staticTexts["4."].exists)
        XCTAssert(app.staticTexts["5."].exists)
        XCTAssertFalse(app.staticTexts["6."].exists)
    }
    
    func testDeleteCellFromSwipe_deletesCell() {
        deleteSite(1)
        XCTAssertEqual(3, table.cells.count)
        
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        
        deleteSite(0)
        XCTAssertEqual(2, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
    }
    
    func testAddsAndDeletes() {
        // Integration test
        deleteSite(2)
        deleteSite(0)
        XCTAssertEqual(2, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        
        addSite(1)
        XCTAssertEqual(3, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
    }
    
    func testReset() {
        deleteSite(2)
        deleteSite(0)
        addSite(1)
        app.buttons["Edit"].tap()
        app.buttons["Reset"].tap()
        
        XCTAssertEqual(4, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
        XCTAssert(app.staticTexts["3."].exists)
        XCTAssert(app.staticTexts["4."].exists)
    }
    
    func testDeleteWhileEditting() {
        app.buttons["Edit"].tap()
        app.buttons["Delete Left Glute"].tap()
        app.buttons["Delete"].tap()
        app.buttons["Delete Right Abdomen"].tap()
        app.buttons["Delete"].tap()
        app.buttons["Done"].tap()
        
        XCTAssertEqual(2, table.cells.count)
        XCTAssert(app.staticTexts["1."].exists)
        XCTAssert(app.staticTexts["2."].exists)
    }
}
