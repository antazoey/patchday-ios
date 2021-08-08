//
//  PillXDaysIntegrationTests.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

class PillXDaysIntegrationTestCase: PDIntegrationTestCase {

    private var daysOne = 0
    private var daysTwo = 0
    private var daysGap = 0

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

    /// Override method to set test arguments.
    open func getArguments() -> (daysOne: Int, daysTwo: Int, daysGap: Int) {
        (0, 0, 0)
    }

    override func beforeEach() {
        super.beforeEach()
        let arguments = getArguments()
        setUpTest(
            daysOne: arguments.daysOne, daysTwo: arguments.daysTwo, daysGap: arguments.daysGap
        )
    }

    func setUpTest(daysOne: Int, daysTwo: Int, daysGap: Int=1) {
        self.daysOne = daysOne
        self.daysTwo = daysTwo
        self.daysGap = daysGap
        alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)
        let table = PillsTable(tableView, pills: sdk.pills)
        pillsViewModel = PillsViewModel(
            alertFactory: alertFactory,
            table: table,
            dependencies: dependencies,
            now: now
        )

        // Create new pill for tests
        XCTAssertEqual(newPillIndex, sdk.pills.count)
        pillsViewModel.goToNewPillDetails(pillsViewController: viewController)
        XCTAssertEqual(newPillIndex + 1, sdk.pills.count)

        setDetailViewModel()
    }

    func runTest(file: StaticString = #filePath, line: UInt = #line) {
        detailViewModel.setTimesaday(1)
        selectXDays(file: file, line: line)
        let daysToIncrement = self.daysOne + self.daysTwo + 1
        for i in 0...daysToIncrement {
            let (position, max, isOn) = getPosition(
                daysAfterStart: self.daysGap * i, file: file, line: line
            )
            let expectedText = createExpectedText(position: position, max: max, isOn: isOn)
            takeAndAssert(expectedPositionText: expectedText, file: file, line: line)
            fastForward(hours: 24, file: file, line: line)
        }
    }

    private func selectXDays(file: StaticString = #filePath, line: UInt = #line) {
        detailViewModel.selectExpirationInterval(getXDaysOptionIndex(file: file, line: line))
        XCTAssertEqual(.XDaysOnXDaysOff, detailViewModel.expirationInterval, file: file, line: line)
        XCTAssertEqual("Days on:", detailViewModel.daysOneLabelText, file: file, line: line)
        XCTAssertEqual("Days off:", detailViewModel.daysTwoLabelText, file: file, line: line)

        detailViewModel.selectFromDaysPicker(daysOne - 1, daysNumber: 1)
        detailViewModel.selectFromDaysPicker(daysTwo - 1, daysNumber: 2)
        XCTAssertEqual("\(daysOne)", detailViewModel.daysOn, file: file, line: line)
        XCTAssertEqual("\(daysTwo)", detailViewModel.daysOff, file: file, line: line)
        detailViewModel.save()
    }

    private func getXDaysOptionIndex(file: StaticString = #filePath, line: UInt = #line) -> Index {
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff", file: file, line: line)
            return -1
        }
        return indexToSelect
    }

    private func takeAndAssert(
        expectedPositionText: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        let actual = detailViewModel.daysPositionText
        XCTAssertEqual(expectedPositionText, actual, file: file, line: line)
        take(file: file, line: line)
        XCTAssertEqual(expectedPositionText, actual, file: file, line: line)
    }

    private func take(
        timesTodaySoFar: Int = 1, file: StaticString = #filePath, line: UInt = #line
    ) {
        pillsViewModel.takePill(at: newPillIndex)
        let actual = detailViewModel.pill!.timesTakenToday
        XCTAssertEqual(timesTodaySoFar, actual, file: file, line: line)
    }

    private func fastForward(hours: Int, file: StaticString = #filePath, line: UInt = #line) {
        now.now = TestDateFactory.createTestDate(hoursFrom: hours, file: file, line: line)
        pills._now = now
        for swallowable in pills.all {
            let pill = swallowable as! Pill
            pill._now = now
        }
        sdk.pills.awaken()
        setDetailViewModel()
        XCTAssertEqual(0, detailViewModel.pill!.timesTakenToday, file: file, line: line)
        let days = hours / 24
        let (expectedPosition, expectedMax, expectedIsOn) = getPosition(
            daysAfterStart: days, file: file, line: line
        )
        let expected = createExpectedText(
            position: expectedPosition, max: expectedMax, isOn: expectedIsOn
        )
        let actual = detailViewModel.daysPositionText
        if expected != actual {
            XCTFail("\(expected) not equal to \(actual)", file: file, line: line)
            return
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
        let defaultReturn = (-1, -1, true)
        if daysAfterStart < 1 {
            XCTFail("daysFromNow should be positive.", file: file, line: line)
            return defaultReturn
        }
        var position = 1
        var isOn = true
        let getMax = [true: daysOne, false: daysTwo]
        var max = -1
        for i in 1...daysAfterStart {
            max = getMax[isOn] ?? -1
            position = i + 1
            if position > max {
                position = 1
                isOn = !isOn
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
        XCTAssertEqual(expected, detailViewModel.daysPositionText, file: file, line: line)
    }
}

class PillXDays_WhenDaysOneIsTwoDaysTwoIsTwoTwentyFourHourGap: PillXDaysIntegrationTestCase {

    override func getArguments() -> (daysOne: Int, daysTwo: Int, daysGap: Int) {
        (2, 2, 24)
    }

    func test() {
        runTest()
    }
}

class PillXDays_WhenDaysOneIsThreeDaysTwoIsFourtyEightHourGap: PillXDaysIntegrationTestCase {

    override func getArguments() -> (daysOne: Int, daysTwo: Int, daysGap: Int) {
        (3, 4, 48)
    }

    func test() {
        runTest()
    }
}
