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
    
    func testTitle_isSites() throws {
        XCTAssert(app.staticTexts["Sites"].exists)
    }

    func testCellCount_reflectsDeliveryMethod() throws {
        XCTAssertEqual(4, table.cells.count)
        
        // Go to Patches and tap Settings gear button.
        tabs.buttons["Patches"].tap()
        app.buttons["settingsGearButton"].tap()
        XCTAssert(app.staticTexts["Settings"].exists)
        XCTAssert(app.staticTexts["Delivery method:"].exists)
        
        // The default setting should be set to Patches.
        // Change it to Injections.
        XCTAssert(app.staticTexts["Patches"].exists)
        app.buttons["deliveryMethodButton"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Injections")
        app.buttons["deliveryMethodButton"].tap()  // Save
        
        // Go back to Sites and make sure the sites count has adjusted.
        tabs.buttons["Sites"].tap()
        XCTAssertEqual(6, table.cells.count)
    }
    
    func testTable_whenAddingRemovingAndResetting_reflectsUpdates() throws {
        // Tap new site button should bring up a fresh details page.
        app.buttons["insertNewSiteButton"].tap()
        XCTAssert(app.staticTexts["New Site"].exists)
        app.buttons["Type"].tap()
        
        // Change the site name from `"New Site"` to `"TEST_SITE"`
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: "New Site".count)
        app.textFields.element.typeText("\(deleteString)TEST_SITE")
        
        // Save and wait for new site cell to appear
        app.buttons["Save"].tap()
        _ = app.wait(for: .unknown, timeout: 5)
        XCTAssertEqual(5, table.cells.count)
    }
}
