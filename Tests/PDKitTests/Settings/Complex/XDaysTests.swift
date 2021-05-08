//
//  XDaysTests.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class XDaysUDTests: XCTestCase {
    func testDays_returnsExpectedValue() {
        let xDays = XDaysUD("23")
        let actual = xDays.days
        let expected = 23
        XCTAssertEqual(expected, actual)
    }

    func testHours_returnsExpectedValue() {
        let xDays = XDaysUD("2")
        let actual = xDays.hours
        let expected = 48
        XCTAssertEqual(expected, actual)
    }
}
