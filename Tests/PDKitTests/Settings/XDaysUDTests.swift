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
        let expected = 23.0
        XCTAssertEqual(expected, actual)
    }

    func testHours_returnsExpectedValue() {
        let xDays = XDaysUD("2")
        let actual = xDays.hours
        let expected = 48
        XCTAssertEqual(expected, actual)
    }

    func testExtract_whenSingleDigitWholeNumber_extractsDays() {
        let testString = "Every 5 Days"
        let expected = "5.0"
        let actual = XDaysUD.extract(testString)
        XCTAssertEqual(expected, actual)
    }

    func testExtract_whenDoubleDigitWholeNumber_extractsDays() {
        let testString = "Every 12 Days"
        let expected = "12.0"
        let actual = XDaysUD.extract(testString)
        XCTAssertEqual(expected, actual)
    }

    func testExtract_whenSingleDigitHalfNumber_extractsDays() {
        let testString = "Every 5 And A Half Days"
        let expected = "5.5"
        let actual = XDaysUD.extract(testString)
        XCTAssertEqual(expected, actual)
    }

    func testExtract_whenDoubleDigitHalfNumber_extractsDays() {
        let testString = "Every 12 And A Half Days"
        let expected = "12.5"
        let actual = XDaysUD.extract(testString)
        XCTAssertEqual(expected, actual)
    }

    func testExtract_whenGivenInvalidString_returnsEmptyString() {
        let testString = "Blipity Blop"
        let expected = ""
        let actual = XDaysUD.extract(testString)
        XCTAssertEqual(expected, actual)
    }
}
