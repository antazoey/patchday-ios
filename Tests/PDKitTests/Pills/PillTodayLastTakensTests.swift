//
//  PillTodayLastTakensTests.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit
import PDMock

class PillTodayLastTakensTests: XCTestCase {

    func testDates_whenNoDateString_returnsZeroItems() {
        let lastTakensObject = PillTodayLastTakens(dateString: nil)
        let actual = lastTakensObject.dates
        XCTAssertEqual(0, actual.count)
    }

    func testDates_returnsDatesCalculatedFromInitString() {
        let testDateOne = Date()
        let testDateTwo = DateFactory.createDate(byAddingMinutes: 5, to: testDateOne)!
        let formatter = ISO8601DateFormatter()
        let testDateOneString = formatter.string(from: testDateOne)
        let testDateTwoString = formatter.string(from: testDateTwo)
        let initString = "\(testDateOneString),\(testDateTwoString)"
        let lastTakensObject = PillTodayLastTakens(dateString: initString)
        let actual = lastTakensObject.dates

        if actual.count != 2 {
            XCTFail("Did not calculate the correct number of dates.")
            return
        }

        XCTAssert(PDTest.equiv(testDateOne, actual[0]))
        XCTAssert(PDTest.equiv(testDateTwo, actual[1]))
    }

    func testSplitLast_decreasesCount() {
        
    }
}
