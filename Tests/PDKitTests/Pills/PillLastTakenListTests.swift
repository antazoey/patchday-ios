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

class PillLastTakenListTests: XCTestCase {

    private let formatter = ISO8601DateFormatter()
    private let testDateOne = Date()

    private var testDateTwo: Date {
        DateFactory.createDate(byAddingMinutes: 5, to: testDateOne)!
    }

    private var testDateOneString: String {
        formatter.string(from: testDateOne)
    }

    private var testDateTwoString: String {
        formatter.string(from: testDateTwo)
    }

    func testDates_whenNoDateString_returnsZeroItems() {
        let lastTakensObject = PillLastTakenList(dateString: nil)
        let actual = lastTakensObject.dates
        XCTAssertEqual(0, actual.count)
    }

    func testDates_returnsDatesCalculatedFromInitString() {
        let initString = "\(testDateOneString),\(testDateTwoString)"
        let lastTakens = PillLastTakenList(dateString: initString)
        let actual = lastTakens.dates

        if actual.count < 2 {
            XCTFail("Did not calculate enough dates.")
            return
        }

        XCTAssert(isDateOne(actual[0]))
        XCTAssert(isDateTwo(actual[1]))
    }

    func testDates_returnsExpectedNumberOfDates() {
        let testDateString = "2021-04-27T20:48:26+00:00,2021-04-27T20:48:26+00:00"
        let lastTakens = PillLastTakenList(dateString: testDateString)
        let actual = lastTakens.dates
        XCTAssertEqual(2, actual.count)
    }

    func testPopLast_decreasesCount() {
        let testDateString = "2021-04-27T20:48:26+00:00,2021-04-27T20:48:26+00:00"
        let lastTakens = PillLastTakenList(dateString: testDateString)
        lastTakens.popLast()
        XCTAssertEqual(1, lastTakens.count)
    }

    func testPopLast_returnsLastDate() {
        let initString = "\(testDateOneString),\(testDateTwoString)"
        let lastTakens = PillLastTakenList(dateString: initString)
        let actual = lastTakens.popLast()

        guard let actualDate = actual else {
            XCTFail("actualDate should not be nil")
            return
        }

        let failureMessage = "\(actualDate) is not equal to \(testDateOne)"
        XCTAssert(isDateTwo(actualDate), failureMessage)
    }

    func testPopLast_maintainsCorrectDatesAndDateStringAfter() {
        let initString = "\(testDateOneString),\(testDateTwoString)"
        let lastTakens = PillLastTakenList(dateString: initString)
        lastTakens.popLast()
        let dates = lastTakens.dates
        XCTAssertEqual(1, dates.count)
        XCTAssert(isDateOne(dates[0]))
        XCTAssertEqual(testDateOneString, lastTakens.dateString)
    }

    func testPopLast_whenInitWithEmptyString_returnsNil() {
        let lastTakens = PillLastTakenList(dateString: "")
        let actual = lastTakens.popLast()
        XCTAssertNil(actual)
    }

    func testPopLast_whenInitWithNil_returnsNil() {
        let lastTakens = PillLastTakenList(dateString: nil)
        let actual = lastTakens.popLast()
        XCTAssertNil(actual)
    }

    func testCombineWith_incrementsCount() {
        let lastTakens = PillLastTakenList(dateString: testDateOneString)
        lastTakens.combineWith(lastTaken: testDateTwo)
        XCTAssertEqual(2, lastTakens.count)
    }

    func testCombineWith_returnsExpectedString() {
        let lastTakens = PillLastTakenList(dateString: testDateOneString)
        let actual = lastTakens.combineWith(lastTaken: testDateTwo)
        XCTAssertEqual("\(testDateOneString),\(testDateTwoString)", actual)
    }

    func testCombineWith_maintainsCorrectDatesAndDateStringAfter() {
        let lastTakens = PillLastTakenList(dateString: testDateOneString)
        lastTakens.combineWith(lastTaken: testDateTwo)
        XCTAssertEqual("\(testDateOneString),\(testDateTwoString)", lastTakens.dateString)
        XCTAssert(isDateOne(lastTakens.dates[0]))
        XCTAssert(isDateTwo(lastTakens.dates[1]))
    }

    func testCombineWith_whenAddingFirstDate_returnsExpectedString() {
        let lastTakens = PillLastTakenList(dateString: nil)
        let actual = lastTakens.combineWith(lastTaken: testDateOne)
        XCTAssertEqual("\(testDateOneString)", actual)
    }

    func testCombineWith_whenAddingFirstDate_maintainsStatefulProperties() {
        let lastTakens = PillLastTakenList(dateString: nil)
        lastTakens.combineWith(lastTaken: testDateOne)

        if lastTakens.count != 1 {
            XCTFail("Did not calculate enough dates.")
            return
        }

        XCTAssertEqual("\(testDateOneString)", lastTakens.dateString)
        XCTAssert(isDateOne(lastTakens.dates[0]))
    }

    private func isDateOne(_ actual: Date) -> Bool {
        PDTest.equiv(testDateOne, actual)
    }

    private func isDateTwo(_ actual: Date) -> Bool {
        PDTest.equiv(testDateTwo, actual)
    }
}
