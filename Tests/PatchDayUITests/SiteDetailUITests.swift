//
//  SiteDetailUITests.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 5/27/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit

class SitesDetailsUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
        app.buttons["insertNewSiteButton"].tap()
    }

    func testTitle() {
        XCTAssert(app.staticTexts["New Site"].exists)
    }
}
