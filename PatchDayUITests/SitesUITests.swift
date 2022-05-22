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
        tabs = XCUIApplication().tabBars
    }
    
    func testTitle() throws {
        tabs.buttons["Sites"].tap()
        XCTAssert(app.staticTexts["Sites"].exists)
    }

    func testCellCount() throws {
        tabs.buttons["Sites"].tap()
        XCTAssertEqual(4, app.tables.matching(.table, identifier: "sitesTableView").cells.count)
        
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
        XCTAssertEqual(6, app.tables.matching(.table, identifier: "sitesTableView").cells.count)
    }
}
