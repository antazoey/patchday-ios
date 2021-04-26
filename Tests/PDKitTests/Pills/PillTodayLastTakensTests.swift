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


class PillTodayLastTakensTests: XCTestCase {
    func testDates_returnsDatesCalculatedFromInitString() {
        let testDateOne = Date()
        let testDateTwo = DateFactory.createDate(byAddingMinutes: 5, to: testDateOne)!
        let testDateOneString = PDDateFormatter.formatDate(testDateOne)
        let testDateTwoString = PDDateFormatter.formatDate(testDateTwo)
        let initString = "\(testDateOneString),\(testDateTwoString)"
        let lastTakensObject = PillTodayLastTakens(dateString: initString)
        let actual = lastTakensObject.dates

        if actual.count != 2 {
            XCTFail("Did not calculate the correct number of dates.")
            return
        }

        XCTAssertEqual(testDateOne, actual[0])
        XCTAssertEqual(testDateTwo, actual[1])
    }
}
