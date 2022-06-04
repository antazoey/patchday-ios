//
//  HormonesUITest.swift
//  PatchDayUITests
//
//  Created by Juliya Smith on 6/2/22.
//  Copyright © 2022 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit

class HormonesUITests: PDUITest {
    func testTitle() throws {
        XCTAssert(app.staticTexts["Patches"].exists)
    }
}
