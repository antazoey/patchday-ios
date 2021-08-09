//
//  PillXDaysIntegrationTestCase.swift
//  PDTest
//
//  Created by Juliya Smith on 8/8/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

class PillXDaysIntegrationTestCase: PDIntegrationTestCase {

    private var timesaday = 0
    private var daysOne = 0
    private var daysTwo = 0
    private var daysGap = 0
    private var currentDay = 0

    private let newPillIndex = 2
    private let viewController = UIViewController()
    private let tableView = UITableView()
    private let mockPillsTable = MockPillsTable()
    private var alertFactory: AlertFactory!
    private var pillsViewModel: PillsViewModel!
    private var detailViewModel: PillDetailViewModel!

    private var pills: PillSchedule {
        sdk.pills as! PillSchedule
    }

    private var currentDayLogString: String {
        "currentDay=\(currentDay)"
    }

    func testGetPosition() {
        daysOne = 3
        daysTwo = 4
        assertExpectedPosition((1, 3, true), getPosition(daysAfterStart: 0))
        assertExpectedPosition((2, 3, true), getPosition(daysAfterStart: 1))
        assertExpectedPosition((3, 3, true), getPosition(daysAfterStart: 2))
        assertExpectedPosition((1, 4, false), getPosition(daysAfterStart: 3))
        assertExpectedPosition((2, 4, false), getPosition(daysAfterStart: 4))
        assertExpectedPosition((3, 4, false), getPosition(daysAfterStart: 5))
        assertExpectedPosition((4, 4, false), getPosition(daysAfterStart: 6))
        assertExpectedPosition((1, 3, true), getPosition(daysAfterStart: 7))
        daysOne = 0
        daysTwo = 0
    }

    private func assertExpectedPosition(_ actual: (Int, Int, Bool), _ expected: (Int, Int, Bool)) {
        XCTAssertEqual(expected.0, actual.0, "Do not have equal positions")
        XCTAssertEqual(expected.1, actual.1, "Do not have equal limits")
        XCTAssertEqual(expected.2, actual.2, "Do not have equal isOns")
    }

    func testExpectedText_whenOnAtFirst_returnsExpectedText() {
        let expected = "Current position: 1 of 5 (on)"
        let actual = createExpectedText(position: 1, max: 5, isOn: true)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOnInMiddle_returnsExpectedText() {
        let expected = "Current position: 3 of 5 (on)"
        let actual = createExpectedText(position: 3, max: 5, isOn: true)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOnAtPenultimate_returnsExpectedText() {
        let expected = "Current position: 4 of 5 (on)"
        let actual = createExpectedText(position: 4, max: 5, isOn: true)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOnAtLast_returnsExpectedText() {
        let expected = "Current position: 5 of 5 (on)"
        let actual = createExpectedText(position: 5, max: 5, isOn: true)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOffAtFirst_returnsExpectedText() {
        let expected = "Current position: 1 of 5 (off)"
        let actual = createExpectedText(position: 1, max: 5, isOn: false)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOffInMiddle_returnsExpectedText() {
        let expected = "Current position: 3 of 5 (off)"
        let actual = createExpectedText(position: 3, max: 5, isOn: false)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOffAtPenultimate_returnsExpectedText() {
        let expected = "Current position: 4 of 5 (off)"
        let actual = createExpectedText(position: 4, max: 5, isOn: false)
        XCTAssertEqual(expected, actual)
    }

    func testExpectedText_whenOffAtLast_returnsExpectedText() {
        let expected = "Current position: 5 of 5 (off)"
        let actual = createExpectedText(position: 5, max: 5, isOn: false)
        XCTAssertEqual(expected, actual)
    }

    func runTest(
        timesaday: Int,
        daysOne: Int,
        daysTwo: Int,
        daysGap: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        setUpTest(timesaday: timesaday, daysOne: daysOne, daysTwo: daysTwo, daysGap: daysGap)
        let daysToIncrement = self.daysOne + self.daysTwo + 1
        for i in 0...daysToIncrement {
            let (position, max, isOn) = getPosition(
                daysAfterStart: self.daysGap * i, file: file, line: line
            )
            let expected = createExpectedText(position: position, max: max, isOn: isOn)
            takeAndAssert(expectedPositionText: expected, file: file, line: line)
            fastForward(days: self.daysGap * (i + 1), file: file, line: line)
            currentDay += 1
        }
    }

    func setUpTest(
        timesaday: Int,
        daysOne: Int,
        daysTwo: Int,
        daysGap: Int, file: StaticString = #filePath,
        line: UInt = #line
    ) {
        self.timesaday = timesaday
        self.daysOne = daysOne
        self.daysTwo = daysTwo
        self.daysGap = daysGap
        alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)
        let table = MockPillsTable()
        pillsViewModel = PillsViewModel(
            alertFactory: alertFactory,
            table: table,
            dependencies: dependencies,
            now: now
        )

        let failMessage = "Failed during test setup"

        // Create new pill for tests
        assertEqual(newPillIndex, sdk.pills.count, failMessage, file: file, line: line)
        pillsViewModel.goToNewPillDetails(pillsViewController: viewController)
        assertEqual(newPillIndex + 1, sdk.pills.count, failMessage, file: file, line: line)

        setDetailViewModel()

        detailViewModel.setTimesaday(self.timesaday)
        selectXDays(failMessage: failMessage, file: file, line: line)
    }

    private func selectXDays(
        failMessage: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        detailViewModel.selectExpirationInterval(getXDaysOptionIndex(failMessage: failMessage))
        let actualInterval = detailViewModel.expirationInterval
        let actualDaysOneText = detailViewModel.daysOneLabelText
        let actualDaysTwoText = detailViewModel.daysTwoLabelText
        assertEqual(.XDaysOnXDaysOff, actualInterval, failMessage, file: file, line: line)
        assertEqual("Days on:", actualDaysOneText, failMessage, file: file, line: line)
        assertEqual("Days off:", actualDaysTwoText, failMessage, file: file, line: line)

        detailViewModel.selectFromDaysPicker(daysOne - 1, daysNumber: 1)
        detailViewModel.selectFromDaysPicker(daysTwo - 1, daysNumber: 2)
        assertEqual("\(daysOne)", detailViewModel.daysOn, failMessage, file: file, line: line)
        assertEqual("\(daysTwo)", detailViewModel.daysOff, failMessage, file: file, line: line)
        detailViewModel.save()
    }

    private func getXDaysOptionIndex(
        failMessage: String, file: StaticString = #filePath, line: UInt = #line
    ) -> Index {
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            fail("Unable to select .XDaysOnXDaysOff - \(failMessage)", file: file, line: line)
            return -1
        }
        return indexToSelect
    }

    private func takeAndAssert(
        expectedPositionText: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let actual = detailViewModel.daysPositionText
        let expected = expectedPositionText
        assertEqual(expected, actual, "beforeTake", file: file, line: line)
        take(file: file, line: line)
        assertEqual(expected, actual, "afterTake", file: file, line: line)
    }

    private func take(file: StaticString = #filePath, line: UInt = #line) {
        pillsViewModel.takePill(at: newPillIndex)
        setDetailViewModel()
        guard let pill = detailViewModel.pill else {
            fail("Pill is nil")
            return
        }
        let actual = pill.timesTakenToday
        let expected = pill.expirationInterval.xDaysIsOn! ? 1 : 0
        let message = "Pill was not taken expected number of times"
        assertEqual(expected, actual, message, file: file, line: line)
    }

    private func fastForward(days: Int, file: StaticString = #filePath, line: UInt = #line) {
        setAllPillsNow(daysFromActualNow: days)
        pills.awaken()
        setDetailViewModel()

        guard let pill = detailViewModel.pill else {
            fail("Pill is nil")
            return
        }

        if days > 0, pill.timesTakenToday != 0 {
            let prefix = "Pill did not awaken correctly"
            let timesTakenString = "timesTakenToday still \(pill.timesTakenToday)"
            fail("\(prefix); \(timesTakenString)")
            return
        }
        let (expectedPosition, expectedMax, expectedIsOn) = getPosition(
            daysAfterStart: days, file: file, line: line
        )
        let expected = createExpectedText(
            position: expectedPosition, max: expectedMax, isOn: expectedIsOn
        )
        let actual = detailViewModel.daysPositionText
        assertEqual(expected, actual, file: file, line: line)
    }

    private func setAllPillsNow(
        daysFromActualNow: Int, file: StaticString = #filePath, line: UInt = #line
    ) {
        now.now = TestDateFactory.createTestDate(
            daysFrom: daysFromActualNow, file: file, line: line
        )
        pills._now = now
        for swallowable in pills.all {
            guard let pill = swallowable as? Pill else {
                fail("Not of type Pill.", file: file, line: line)
                return
            }
            pill._now = now
        }
        if daysFromActualNow > 0 {
            verifyPillNotWokeUp(file: file, line: line)
        }
    }

    private func verifyPillNotWokeUp(file: StaticString = #filePath, line: UInt = #line) {
        for pill in pills.all {
            let failMessage = "pill woke up today when it should have reset"
            assertFalse(pill.wokeUpToday, failMessage, file: file, line: line)
        }
    }

    private func setDetailViewModel() {
        detailViewModel = PillDetailViewModel(newPillIndex, dependencies: dependencies, now: now)
    }

    /// Returns position information based on the current days from the testing start date.
    private func getPosition(
        daysAfterStart: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (Index, Int, Bool) {
        if daysAfterStart < 0 {
            fail("daysFromNow should be positive.", file: file, line: line)
            return (-1, -1, true)
        }
        var position = 0
        var isOn = true
        let getMax = [true: daysOne, false: daysTwo]
        var max = daysOne
        for _ in 0...daysAfterStart {
            position += 1
            max = getMax[isOn]!
            if position > max {
                position = 1
                isOn = !isOn
                max = getMax[isOn]!
            }
        }
        return (position, max, isOn)
    }

    private func createExpectedText(position: Int, max: Int, isOn: Bool) -> String {
        let isOnString = isOn ? "on" : "off"
        return "Current position: \(position) of \(max) (\(isOnString))"
    }

    private func assertPositionText(
        expected: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let actual = detailViewModel.daysPositionText
        assertEqual(expected, actual)
    }

    private func assertEqual<T>(
        _ expected: T?,
        _ actual: T?,
        _ failMessage: String="",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T:Equatable {
        let message = failMessage == ""
            ? currentDayLogString
            : combineMessages(failMessage, _messageTwo: currentDayLogString)
        XCTAssertEqual(expected, actual, message, file: file, line: line)
    }

    private func assertFalse(
        _ actual: Bool,
        _ failMessage: String="",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(actual, currentDayLogString, file: file, line: line)
    }

    private func fail(
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTFail(combineMessages(message, _messageTwo: currentDayLogString), file: file, line: line)
    }

    private func combineMessages(_ messageOne: String, _messageTwo: String) -> String {
        "\(messageOne); \(_messageTwo)"
    }
}
