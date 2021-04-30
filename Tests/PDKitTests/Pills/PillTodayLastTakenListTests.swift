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

    func testAsList_whenNotimeString_returnsZeroItems() {
        let lastTakensObject = PillTimesTakenTodayList(timeString: nil)
        let actual = lastTakensObject.asList
        XCTAssertEqual(0, actual.count)
    }

    func testAsList_returnstimesCalculatedFromInitString() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        tprint(initString)
        let lastTakens = PillTimesTakenTodayList(timeString: initString)
        let actual = lastTakens.asList

        if actual.count < 2 {
            XCTFail("Did not calculate enough times.")
            return
        }

        XCTAssert(isTimeOne(actual[0]))
        XCTAssert(isTimeTwo(actual[1]))
    }

    func testAsList_returnsExpectedNumberOftimes() {
        let testtimeString = "12:00:10,12:00:20"
        let lastTakens = PillTimesTakenTodayList(timeString: testtimeString)
        let actual = lastTakens.asList
        XCTAssertEqual(2, actual.count)
    }

    func testUndoLast_decreasesCount() {
        let testtimeString = "12:00:10,12:00:20"
        let lastTakens = PillTimesTakenTodayList(timeString: testtimeString)
        lastTakens.undoLast()
        XCTAssertEqual(1, lastTakens.count)
    }

    func testUndoLast_whenOnlyOne_decreasesCountToZero() {
        let testtimeString = "12:00:10"
        let lastTakens = PillTimesTakenTodayList(timeString: testtimeString)
        lastTakens.undoLast()
        XCTAssertEqual(0, lastTakens.count)
    }

    func testUndoLast_whenInitWithEmptyString_returnsNil() {
        let lastTakens = PillTimesTakenTodayList(timeString: "")
        let actual = lastTakens.undoLast()
        XCTAssertNil(actual)
    }

    func testUndoLast_whenInitWithNil_returnsNil() {
        let lastTakens = PillTimesTakenTodayList(timeString: nil)
        let actual = lastTakens.undoLast()
        XCTAssertNil(actual)
    }

    func testUndoLast_returnsPenultimateTime() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        let lastTakens = PillTimesTakenTodayList(timeString: initString)
        let actual = lastTakens.undoLast()

        guard let actualtime = actual else {
            XCTFail("actual should not be nil")
            return
        }

        let failureMessage = "\(actualtime) is not equal to \(testTimeOne)"
        XCTAssert(isTimeOne(actualtime), failureMessage)
    }

    func testUndoLast_maintainsCorrectTimesAndTimeStringAfter() {
        let initString = "\(testTimeOneString),\(testTimeTwoString)"
        let lastTakens = PillTimesTakenTodayList(timeString: initString)
        lastTakens.undoLast()
        let times = lastTakens.asList
        XCTAssertEqual(1, times.count)

        if lastTakens.count < 1 {
            XCTFail("Does not have enough times")
            return
        }

        XCTAssert(isTimeOne(times[0]))
        XCTAssertEqual(testTimeOneString, lastTakens.asString)
    }

    func testCombineWith_incrementsCount() {
        let lastTakens = PillTimesTakenTodayList(timeString: testTimeOneString)
        lastTakens.combineWith(testTimeTwo)
        XCTAssertEqual(2, lastTakens.count)
    }

    func testCombineWith_returnsExpectedString() {
        let lastTakens = PillTimesTakenTodayList(timeString: testTimeOneString)
        let actual = lastTakens.combineWith(testTimeTwo)
        XCTAssertEqual("\(testTimeOneString),\(testTimeTwoString)", actual)
    }

    func testCombineWith_maintainsCorrecttimesAndtimeStringAfter() {
        let lastTakens = PillTimesTakenTodayList(timeString: testTimeOneString)
        lastTakens.combineWith(testTimeTwo)
        XCTAssertEqual("\(testTimeOneString),\(testTimeTwoString)", lastTakens.asString)

        if lastTakens.count < 2 {
            XCTFail("Does not have enough times.")
            return
        }

        XCTAssert(isTimeOne(lastTakens.asList[0]))
        XCTAssert(isTimeTwo(lastTakens.asList[1]))
    }

    func testCombineWith_whenInitWithNil_returnsExpectedString() {
        let lastTakens = PillTimesTakenTodayList(timeString: nil)
        let actual = lastTakens.combineWith(testTimeOne)
        XCTAssertEqual("\(testTimeOneString)", actual)
    }

    func testCombineWith_whenInitWithEmptyString_returnsExpectedString() {
        let lastTakens = PillTimesTakenTodayList(timeString: "")
        let actual = lastTakens.combineWith(testTimeOne)
        XCTAssertEqual("\(testTimeOneString)", actual)
    }

    func testCombineWith_whenAddingFirstTime_maintainsStatefulProperties() {
        let lastTakens = PillTimesTakenTodayList(timeString: nil)
        lastTakens.combineWith(testTimeOne)

        if lastTakens.count != 1 {
            XCTFail("Did not calculate enough times.")
            return
        }

        XCTAssertEqual("\(testTimeOneString)", lastTakens.asString)
        XCTAssert(isTimeOne(lastTakens.asList[0]))
    }

    private func isTimeOne(_ actual: Time) -> Bool {
        PDTest.equiv(testTimeOne, actual)
    }

    private func isTimeTwo(_ actual: Time) -> Bool {
        PDTest.equiv(testTimeTwo, actual)
    }
}
