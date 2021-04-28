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

    private let testTimeOne = Time()

    private var testTimeTwo: Time {
        DateFactory.createDate(byAddingMinutes: 5, to: testTimeOne)!
    }

    private var testTimeOneString: String {
        PDDateFormatter.formatInternalTime(testTimeOne)
    }

    private var testTimeTwoString: String {
        PDDateFormatter.formatInternalTime(testTimeTwo)
    }

    func testTimes_whenNotimeString_returnsZeroItems() {
        let lastTakensObject = PillTodayLastTakenList(timeString: nil)
        let actual = lastTakensObject.times
        XCTAssertEqual(0, actual.count)
    }

    func testTimes_returnstimesCalculatedFromInitString() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        tprint(initString)
        let lastTakens = PillTodayLastTakenList(timeString: initString)
        let actual = lastTakens.times

        if actual.count < 2 {
            XCTFail("Did not calculate enough times.")
            return
        }

        XCTAssert(isTimeOne(actual[0]))
        XCTAssert(isTimeTwo(actual[1]))
    }

    func testtimes_returnsExpectedNumberOftimes() {
        let testtimeString = "12:00:10,12:00:20"
        let lastTakens = PillTodayLastTakenList(timeString: testtimeString)
        let actual = lastTakens.times
        XCTAssertEqual(2, actual.count)
    }

    func testPopLast_decreasesCount() {
        let testtimeString = "12:00:10,12:00:20"
        let lastTakens = PillTodayLastTakenList(timeString: testtimeString)
        lastTakens.popLast()
        XCTAssertEqual(1, lastTakens.count)
    }

    func testPopLast_returnsLasttime() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        let lastTakens = PillTodayLastTakenList(timeString: initString)
        let actual = lastTakens.popLast()

        guard let actualtime = actual else {
            XCTFail("actual should not be nil")
            return
        }

        let failureMessage = "\(actualtime) is not equal to \(testTimeOne)"
        XCTAssert(isTimeTwo(actualtime), failureMessage)
    }

    func testPopLast_maintainsCorrectTimesAndTimeStringAfter() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        let lastTakens = PillTodayLastTakenList(timeString: initString)
        lastTakens.popLast()
        let times = lastTakens.times
        XCTAssertEqual(1, times.count)

        if lastTakens.count < 1 {
            XCTFail("Does not have enough times")
            return
        }

        XCTAssert(isTimeOne(times[0]))
        XCTAssertEqual(testTimeOneString, lastTakens.timeString)
    }

    func testPopLast_whenInitWithEmptyString_returnsNil() {
        let lastTakens = PillTodayLastTakenList(timeString: "")
        let actual = lastTakens.popLast()
        XCTAssertNil(actual)
    }

    func testPopLast_whenInitWithNil_returnsNil() {
        let lastTakens = PillTodayLastTakenList(timeString: nil)
        let actual = lastTakens.popLast()
        XCTAssertNil(actual)
    }

    func testCombineWith_incrementsCount() {
        let lastTakens = PillTodayLastTakenList(timeString: testTimeOneString)
        lastTakens.combineWith(lastTaken: testTimeTwo)
        XCTAssertEqual(2, lastTakens.count)
    }

    func testCombineWith_returnsExpectedString() {
        let lastTakens = PillTodayLastTakenList(timeString: testTimeOneString)
        let actual = lastTakens.combineWith(lastTaken: testTimeTwo)
        XCTAssertEqual("\(testTimeOneString),\(testTimeTwoString)", actual)
    }

    func testCombineWith_maintainsCorrecttimesAndtimeStringAfter() {
        let lastTakens = PillTodayLastTakenList(timeString: testTimeOneString)
        lastTakens.combineWith(lastTaken: testTimeTwo)
        XCTAssertEqual("\(testTimeOneString),\(testTimeTwoString)", lastTakens.timeString)

        if lastTakens.count < 2 {
            XCTFail("Does not have enough times.")
            return
        }

        XCTAssert(isTimeOne(lastTakens.times[0]))
        XCTAssert(isTimeTwo(lastTakens.times[1]))
    }

    func testCombineWith_whenAddingFirsttime_returnsExpectedString() {
        let lastTakens = PillTodayLastTakenList(timeString: nil)
        let actual = lastTakens.combineWith(lastTaken: testTimeOne)
        XCTAssertEqual("\(testTimeOneString)", actual)
    }

    func testCombineWith_whenAddingFirsttime_maintainsStatefulProperties() {
        let lastTakens = PillTodayLastTakenList(timeString: nil)
        lastTakens.combineWith(lastTaken: testTimeOne)

        if lastTakens.count != 1 {
            XCTFail("Did not calculate enough times.")
            return
        }

        XCTAssertEqual("\(testTimeOneString)", lastTakens.timeString)
        XCTAssert(isTimeOne(lastTakens.times[0]))
    }

    private func isTimeOne(_ actual: Time) -> Bool {
        PDTest.equiv(testTimeOne, actual)
    }

    private func isTimeTwo(_ actual: Time) -> Bool {
        PDTest.equiv(testTimeTwo, actual)
    }
}
