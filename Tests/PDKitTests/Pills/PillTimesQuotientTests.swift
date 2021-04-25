//
//  PillTimesQuotientTests.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class PillTimesQuotientTests: XCTestCase {
    func testToString_zeroOne_returnsExpectedString() {
        let quotient = PillTimesQuotient(timesTakenToday: 0, timesaday: 1)
        let expected = "0 / 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_oneOne_returnsExpectedString() {
        let quotient = PillTimesQuotient(timesTakenToday: 1, timesaday: 1)
        let expected = "1 / 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_threeFour_returnsExpectedString() {
        let quotient = PillTimesQuotient(timesTakenToday: 3, timesaday: 4)
        let expected = "3 / 4"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_fourFour_returnsExpectedString() {
        let quotient = PillTimesQuotient(timesTakenToday: 4, timesaday: 4)
        let expected = "4 / 4"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_twoOne_returnsExpectedDefaultString() {
        let quotient = PillTimesQuotient(timesTakenToday: 2, timesaday: 1)
        let expected = "1 / 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_negativeTimesTaken_returnsExpectedDefaultString() {
        let quotient = PillTimesQuotient(timesTakenToday: -2, timesaday: 3)
        let expected = "0 / 3"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_negativeTimesaday_returnsExpectedDefaultString() {
        let quotient = PillTimesQuotient(timesTakenToday: 2, timesaday: -3)
        let expected = "1 / 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }
}
