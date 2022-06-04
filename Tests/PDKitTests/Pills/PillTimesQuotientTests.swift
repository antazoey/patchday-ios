//
//  PillTimesQuotientTests.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDTest
@testable
import PDKit

class PillTimesQuotientTests: PDTestCase {
    func testToString_zeroOne() {
        let quotient = PillTimesQuotient(timesTakenToday: 0, timesaday: 1)
        let expected = "0 of 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_oneOne() {
        let quotient = PillTimesQuotient(timesTakenToday: 1, timesaday: 1)
        let expected = "1 of 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_threeFour() {
        let quotient = PillTimesQuotient(timesTakenToday: 3, timesaday: 4)
        let expected = "3 of 4"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_fourFour() {
        let quotient = PillTimesQuotient(timesTakenToday: 4, timesaday: 4)
        let expected = "4 of 4"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_twoOne() {
        let quotient = PillTimesQuotient(timesTakenToday: 2, timesaday: 1)
        let expected = "1 of 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_negativeTimesTaken() {
        let quotient = PillTimesQuotient(timesTakenToday: -2, timesaday: 3)
        let expected = "0 of 3"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }

    func testToString_negativeTimesaday() {
        let quotient = PillTimesQuotient(timesTakenToday: 2, timesaday: -3)
        let expected = "1 of 1"
        let actual = quotient.toString()
        XCTAssertEqual(expected, actual)
    }
}
