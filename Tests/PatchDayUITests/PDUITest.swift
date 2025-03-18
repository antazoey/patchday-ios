//
//  PDUITest.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 5/23/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest

class PDUITest: XCTestCase {

    var app: XCUIApplication!
    var tabs: XCUIElementQuery!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("--nuke-storage")
        app.launch()

        // Dismiss disclaimer that always appears
        addUIInterruptionMonitor(withDescription: "Disclaimer") {
            (alert) -> Bool in
            alert.buttons["Dismiss"].tap()
            return true
        }

        tabs = app.tabBars
        
        XCTAssert(app.staticTexts["Patches"].waitForExistence(timeout: 5))
    }
}
