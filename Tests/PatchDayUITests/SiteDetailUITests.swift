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

class SiteDetailUITests: PDUITest {

    override func setUpWithError() throws {
        try super.setUpWithError()
        tabs.buttons["Sites"].tap()
        app.buttons["insertNewSiteButton"].tap()
    }

    func openNamePicker() {
        app.windows
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element
            .children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .other)
            .element
            .children(matching: .textField)
            .element
            .tap()
    }

    func testTitle() throws {
        XCTAssert(app.staticTexts["New Site"].exists)
    }

    func testWhileTypingSiteName_cannotOpenSiteImagePicker() throws {
        XCTAssertTrue(app.buttons["siteImageButton"].isEnabled)
        app.buttons["Type"].tap()
        XCTAssertFalse(app.buttons["siteImageButton"].isEnabled)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["siteImageButton"].isEnabled)
    }

    func testWhilePickingSiteName_cannotOpenSiteImagePicker() throws {
        XCTAssertTrue(app.buttons["siteImageButton"].isEnabled)
        openNamePicker()
        XCTAssertFalse(app.buttons["siteImageButton"].isEnabled)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["siteImageButton"].isEnabled)
    }
}
