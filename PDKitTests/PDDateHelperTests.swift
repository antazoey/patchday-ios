//
//  PDKitTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PDKit

class PDDateHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDayOfWeek() {
        let d1 = Date(timeIntervalSince1970: 0)
        let dateStr = PDDateHelper.dayOfWeekString(date: d1)
        let expected = "Wednesday, 6:00 PM"
        XCTAssert(dateStr == expected)
    }

}
