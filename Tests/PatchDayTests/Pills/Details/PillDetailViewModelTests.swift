//
//  PillDetailViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/30/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillDetailViewModelTests: XCTestCase {

    private var dependencies: MockDependencies! = nil

    @discardableResult
    private func setupPill() -> MockPill {
        let pill = MockPill()
        dependencies = MockDependencies()
        let schedule = dependencies.sdk?.pills as! MockPillSchedule
        schedule.all = [pill]
        return pill
    }

    func testSelections_defaultToNotHavingAnyAttributesExceptExpirationInterval() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .FirstXDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays, xDays: "5")
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertNil(viewModel.selections.name)
        XCTAssertNil(viewModel.selections.lastTaken)
        XCTAssertNil(viewModel.selections.notify)
        XCTAssertNil(viewModel.selections.times)
        XCTAssertNil(viewModel.selections.xDays)
        XCTAssertNil(viewModel.selections.expirationIntervalSetting)
    }

    func testTitle_whenNew_returnsNewPillTitle() {
        let pill = setupPill()
        pill.isNew = true
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = PDTitleStrings.NewPillTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_returnsEditPillTitle() {
        let pill = setupPill()
        pill.isNew = false
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = PDTitleStrings.EditPillTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testName_returnsSelectedName() {
        let pill = setupPill()
        pill.name = "orig name"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = "selected name"
        let actual = viewModel.name
        let expected = viewModel.selections.name
        XCTAssertEqual(expected, actual)
    }

    func testName_whenNoNameSelected_returnsPillName() {
        let pill = setupPill()
        pill.name = "orig name"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = nil
        let actual = viewModel.name
        let expected = pill.name
        XCTAssertEqual(expected, actual)
    }

    func testNameIsSelected_whenNameSelected_returnsTrue() {
        let pill = setupPill()
        pill.name = "orig name"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = "selected name"
        XCTAssertTrue(viewModel.nameIsSelected)
    }

    func testNameOptions_returnsExpectedNames() {
        let viewModel = PillDetailViewModel(0, dependencies: MockDependencies())
        let expected = PillStrings.DefaultPills + PillStrings.ExtraPills
        let actual = viewModel.nameOptions
        XCTAssertEqual(expected, actual)
    }

    func testNamePickerStartIndex_usesSelectedName() {
        let pill = setupPill()
        pill.name = "yes"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = "Progesterone"
        let actual = viewModel.namePickerStartIndex
        XCTAssertEqual(1, actual)
    }

    func testNamePickerStartIndex_whenNothingSelected_usesPillName() {
        let pill = setupPill()
        pill.name = "Estrogen"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = nil
        let actual = viewModel.namePickerStartIndex
        XCTAssertEqual(2, actual)
    }

    func testNameIsSelected_whenNameNotSelected_returnsFalse() {
        let pill = setupPill()
        pill.name = "orig name"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = nil
        XCTAssertFalse(viewModel.nameIsSelected)
    }

    func testTimesaday_returnsSelectedTimesaday() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00,12:01:00,12:03:00"  //  3
        XCTAssertEqual(3, viewModel.timesaday)
    }

    func testTimesaday_whenNothingSelected_returnsPillTimesaday() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(times.count, viewModel.timesaday)
    }

    func testTimesadayText_returnsExpectedSelectedText() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00,12:01:00,12:03:00"  //  3
        let expected = "How many per day:  3"
        let actual = viewModel.timesadayText
        XCTAssertEqual(expected, actual)
    }

    func testTimesadayText_whenNoTimesSelected_returnsExpectedPillText() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "How many per day:  1"
        let actual = viewModel.timesadayText
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_returnsSelectedInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = .EveryOtherDay
        let actual = viewModel.expirationInterval
        let expected = viewModel.selections.expirationIntervalSetting
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenNothingSelected_returnsPillInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = nil
        let actual = viewModel.expirationInterval
        let expected = pill.expirationIntervalSetting
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalText_returnsSelectedIntervalText() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = .EveryOtherDay
        let actual = viewModel.expirationIntervalText
        let expected = PillStrings.Intervals.EveryOtherDay
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalText_whenNothingSelected_returnsPillIntervalText() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .FirstXDays
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = nil
        let actual = viewModel.expirationIntervalText
        let expected = PillStrings.Intervals.FirstXDays
        XCTAssertEqual(expected, actual)
    }

    func testDaysOn_whenNothingSelected_returnsDaysOnFromPill() {
        let pill = setupPill()
        let expected = "5"
        pill.expirationIntervalSetting = .FirstXDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays, xDays: expected)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.daysOn
        XCTAssertEqual(expected, actual)
    }

    func testDaysOn_whenHasSelectedRow_returnsSelectedValue() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .FirstXDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays, xDays: "5")
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "8"
        viewModel.selections.xDays = expected
        viewModel.selections.expirationIntervalSetting = .FirstXDays
        let actual = viewModel.daysOn
        XCTAssertEqual(expected, actual)
    }

    func testDaysOn_whenNothingSelectedAndPillHasNone_returnsDefault() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = DefaultPillAttributes.xDaysString
        let actual = viewModel.daysOn
        XCTAssertEqual(expected, actual)
    }

    func testDaysOff_whenNothingSelected_returnsDaysOffFromPill() {
        let pill = setupPill()
        let expected = "7"
        pill.expirationIntervalSetting = .XDaysOnXDaysOff
        pill.expirationInterval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-\(expected)")
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.daysOff
        XCTAssertEqual(expected, actual)
    }

    func testDaysOff_whenNothingSelectedAndPillHasNone_returnsDefault() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = DefaultPillAttributes.xDaysString
        let actual = viewModel.daysOff
        XCTAssertEqual(expected, actual)
    }

    func testDaysOff_whenHasSelectedRow_returnsSelectedValue() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .XDaysOnXDaysOff
        pill.expirationInterval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5")
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "8"

        // The UI has to also set the selected interval prior to being able to set the days.
        viewModel.selections.expirationIntervalSetting = .XDaysOnXDaysOff
        viewModel.selections.xDays = "5-\(expected)"
        let actual = viewModel.daysOff
        XCTAssertEqual(expected, actual)
    }


    func testDaysOptions_returnsAListOfStringIntegersFromOneToMax() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.daysOptions
        let expected = [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23",
            "24",
            "25"
        ]
        XCTAssertEqual(expected, actual)
    }

    func testDaysOneLabelText_whenNotUsingXDays_returnsNil() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertNil(viewModel.daysOneLabelText)
    }

    func testDaysOneLabel_whenUsingFirstXDays_returnsExpectedText() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .FirstXDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "First X days of the month:"
        let actual = viewModel.daysOneLabelText
        XCTAssertEqual(expected, actual)
    }

    func testDaysOneLabel_whenUsingLastXDays_returnsExpectedText() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .LastXDays
        pill.expirationInterval = PillExpirationInterval(.LastXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "Last X days of the month:"
        let actual = viewModel.daysOneLabelText
        XCTAssertEqual(expected, actual)
    }

    func testDaysOneLabel_whenUsingXDaysOnXDaysOff_returnsExpectedText() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .XDaysOnXDaysOff
        pill.expirationInterval = PillExpirationInterval(.XDaysOnXDaysOff)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "Days on:"
        let actual = viewModel.daysOneLabelText
        XCTAssertEqual(expected, actual)
    }

    func testDaysTwoLabel_whenNotUsingXDaysOnXDaysOff_returnsNil() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .FirstXDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertNil(viewModel.daysTwoLabelText)
    }

    func testDaysTwoLabel_whenUsingXDaysOnXDaysOff_returnsExpectedText() {
        let pill = setupPill()
        pill.expirationIntervalSetting = .XDaysOnXDaysOff
        pill.expirationInterval = PillExpirationInterval(.XDaysOnXDaysOff)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = "Days off:"
        let actual = viewModel.daysTwoLabelText
        XCTAssertEqual(expected, actual)
    }

    func testGetStartIndexForDaysPicker_whenFirstXDaysAndGiven1AndNothingSelected_returnsDaysIndexFromPill() {
        let pill = setupPill()
        let xDays = "3-14"
        pill.expirationIntervalSetting = .FirstXDays
        pill.xDays = xDays
        pill.expirationInterval = PillExpirationInterval(.FirstXDays, xDays: xDays)
        let expected = 2
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.getStartIndexForDaysPicker(pickerNumber: 1)
        XCTAssertEqual(expected, actual)
    }

    func testGetStartIndexForDaysPicker_whenLastXDaysAndGiven1AndNothingSelected_returnsDaysIndexFromPill() {
        let pill = setupPill()
        let setting = PillExpirationIntervalSetting.LastXDays
        let xDays = "3-14"
        pill.expirationIntervalSetting = setting
        pill.xDays = xDays
        pill.expirationInterval = PillExpirationInterval(setting, xDays: xDays)
        let expected = 2
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.getStartIndexForDaysPicker(pickerNumber: 1)
        XCTAssertEqual(expected, actual)
    }

    func testGetStartIndexForDaysPicker_whenGiven2AndNothingSelected_returnsDaysIndexFromPill() {
        let pill = setupPill()
        let setting = PillExpirationIntervalSetting.XDaysOnXDaysOff
        let xDays = "3-3"
        pill.expirationInterval = PillExpirationInterval(setting, xDays: xDays)
        pill.expirationIntervalSetting = setting
        pill.xDays = xDays
        let expected = 2
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let actual = viewModel.getStartIndexForDaysPicker(pickerNumber: 2)
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalPickerStartIndex_usesSelectedInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = PillExpirationIntervalSetting.LastXDays
        let actual = viewModel.expirationIntervalStartIndex
        XCTAssertEqual(3, actual)
    }

    func testExpirationIntervalPickerStartIndex_whenNothingSelected_usesPillInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval(.FirstXDays)
        pill.expirationIntervalSetting = .FirstXDays
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = nil
        viewModel.selections.name = nil
        let actual = viewModel.expirationIntervalStartIndex
        XCTAssertEqual(2, actual)
    }

    func testExpirationIntervalOptions_returnsExpectedOptions() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let expected = PillStrings.Intervals.all
        let actual = viewModel.expirationIntervalOptions
        XCTAssertEqual(expected, actual)
    }

    func testNotify_whenNotifySelected_returnsNotify() {
        let pill = setupPill()
        pill.notify = false
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.notify = true
        XCTAssert(viewModel.notify)
    }

    func testNotify_whenNotifyNotSelected_returnsPillValue() {
        let pill = setupPill()
        pill.notify = false
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.notify = nil
        XCTAssertFalse(viewModel.notify)
    }

    func testTimes_whenTimesSelected_returnsSelectedTimesCount() {
        let pill = setupPill()
        let times = [Time()]
        let selectedTimes = [
            Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: times[0])
        ]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(selectedTimes)
        XCTAssertEqual(selectedTimes.count, viewModel.timesaday)
    }

    func testTimes_whenNothingSelected_returnsPillTimes() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(times.count, viewModel.times.count)
        XCTAssert(PDTest.sameTime(times[0], viewModel.times[0]))
    }

    func testTimes_whenTimesSelected_returnsSelectedTimes() {
        let pill = setupPill()
        let times = [Time()]
        let selectedTimes = [
            Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: times[0])
        ]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(selectedTimes)
        XCTAssertEqual(selectedTimes, viewModel.times)
    }

    func testTimes_ordersTimes() {
        let now = Date()
        let times = [
            Calendar.current.date(bySettingHour: 12, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!
        ]
        let pill = setupPill()
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(times[1], viewModel.times[0])
        XCTAssertEqual(times[2], viewModel.times[1])
        XCTAssertEqual(times[0], viewModel.times[2])
    }

    func testTimes_setsDateToToday() {
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingHours: 24*32, to: DateFactory.createDefaultDate())!

        let yesterday = DateFactory.createDate(byAddingHours: -24, to: now.now)!
        let times = [
            Calendar.current.date(bySettingHour: 12, minute: 9, second: 9, of: yesterday)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: yesterday)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: yesterday)!
        ]
        let pill = setupPill()
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies, now: now)
        let expected1 = DateFactory.createDate(byAddingHours: 24, to: times[1])
        let expected2 = DateFactory.createDate(byAddingHours: 24, to: times[2])
        let expected3 = DateFactory.createDate(byAddingHours: 24, to: times[0])
        XCTAssertEqual(expected1, viewModel.times[0])
        XCTAssertEqual(expected2, viewModel.times[1])
        XCTAssertEqual(expected3, viewModel.times[2])
    }

    func testSelectTime_whenNothingElseSelected_setExpectedTimeString() {
        let pill = setupPill()
        let times = [Time(), Time(), Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let newTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: times[0])
        viewModel.selectTime(newTime!, 1)
        let expectedTimes = [times[0], newTime, times[2]]
        let expected = PDDateFormatter.convertDatesToCommaSeparatedString(expectedTimes)
        XCTAssertEqual(expected, viewModel.selections.times)
    }

    func testSelectTime_whenHasPreviousSelection_setExpectedTimeString() {
        let pill = setupPill()
        let times = [Time(), Time(), Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let previousSelectedTimes = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: times[0]),
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: times[1]),
            Calendar.current.date(bySettingHour: 13, minute: 13, second: 13, of: times[2])
        ]
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(
            previousSelectedTimes
        )
        let newTime = Calendar.current.date(bySettingHour: 12, minute: 12, second: 12, of: times[0])
        viewModel.selectTime(newTime!, 1)
        let expectedTimes = [previousSelectedTimes[0], newTime, previousSelectedTimes[2]]
        let expected = PDDateFormatter.convertDatesToCommaSeparatedString(expectedTimes)
        XCTAssertEqual(expected, viewModel.selections.times)
    }

    func testSelectTime_whenIndexOutOfRange_doesNothing() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selectTime(Time(), 1)
        XCTAssertEqual(1, viewModel.times.count)
        XCTAssert(PDTest.sameTime(times[0], viewModel.times[0]))
    }

    func testSetTimesday_whenSettingToZero_doesNotSet() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setTimesaday(0)
        XCTAssertEqual(1, viewModel.times.count)
    }

    func testSetTimesday_whenNotChanging_doesNotSet() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setTimesaday(1)
        XCTAssertEqual(1, viewModel.times.count)
        XCTAssert(PDTest.sameTime(times[0], viewModel.times[0]))
    }

    func testSetTimesaday_whenIncreasingAndNoTimeSelected_addsNewTime() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setTimesaday(2)
        XCTAssertEqual(2, viewModel.times.count)
    }

    func testSetTimesaday_whenIncreasingAndTimesPreviouslySelected_addsNewTime() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let previousSelectedTimes = [Time(), Time()]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(
            previousSelectedTimes
        )
        viewModel.setTimesaday(3)
        XCTAssertEqual(3, viewModel.times.count)
    }

    func testSetTimesaday_whenDecreasingAndNoTimeSelected_removesTime() {
        let pill = setupPill()
        let times = [Time(), Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setTimesaday(1)
        XCTAssertEqual(1, viewModel.times.count)
    }

    func testSetTimesaday_whenDecreasingAndTimesPreviouslySelected_addsNewTime() {
        let pill = setupPill()
        let times = [Time(), Time()]
        pill.times = times
        let previousSelectedTimes = [Time(), Time(), Time()]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(
            previousSelectedTimes
        )
        viewModel.setTimesaday(1)
        XCTAssertEqual(1, viewModel.times.count)
    }

    func testSetPickerTimes_setsExpectedTime() {
        let pill = setupPill()
        let now = Date()
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        pill.times = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!
        ]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setPickerTimes(pickers)

        let actualOne = pickers[0].date
        let expectedOne = pill.times[0]
        XCTAssertEqual(expectedOne, actualOne)

        let actualTwo = pickers[1].date
        let expectedTwo = pill.times[1]
        XCTAssertEqual(expectedTwo, actualTwo)

        let actualThree = pickers[2].date
        let expectedThree = pill.times[2]
        XCTAssertEqual(expectedThree, actualThree)
    }

    func testSetPickerTimes_whenNoTimeForIndex_usesCurrentDate() {
        let pill = setupPill()
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        pill.times = []  // No times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.setPickerTimes(pickers)
        for p in pickers {
            XCTAssert(PDTest.equiv(Date(), p.date))
        }
    }

    func testSave_resetsPillAttributes() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = "Test"
        viewModel.save()
        XCTAssertNil(viewModel.selections.name)
    }

    func testSave_resetsSelections() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.name = "Test"
        viewModel.save()
        XCTAssertNil(viewModel.selections.name)
        XCTAssertNil(viewModel.selections.lastTaken)
        XCTAssertNil(viewModel.selections.notify)
        XCTAssertNil(viewModel.selections.times)
        XCTAssertNil(viewModel.selections.xDays)
        XCTAssertNil(viewModel.selections.expirationIntervalSetting)
    }

    func testSave_callsSetPillWithSelections() {
        let pill = setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let name = "Test"
        let time = PDDateFormatter.convertDatesToCommaSeparatedString([Time()])
        let notify = true
        let interval = PillExpirationIntervalSetting.EveryDay
        viewModel.selections.name = name
        viewModel.selections.times = time
        viewModel.selections.notify = notify
        viewModel.selections.expirationIntervalSetting = interval
        let pills = (viewModel.sdk?.pills as! MockPillSchedule)
        viewModel.save()
        XCTAssertEqual(pill.id, pills.setIdCallArgs[0].0)
        XCTAssertEqual(name, pills.setIdCallArgs[0].1.name)
        XCTAssertEqual(time, pills.setIdCallArgs[0].1.times)
        XCTAssertEqual(notify, pills.setIdCallArgs[0].1.notify)
        XCTAssertEqual(interval, pills.setIdCallArgs[0].1.expirationIntervalSetting)
    }

    func testSave_bothCancelsAndRequestsNotifications() {
        let pill = setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.save()
        let nots = viewModel.notifications as! MockNotifications
        XCTAssertEqual(pill.id, nots.cancelDuePillNotificationCallArgs[0].id)
        XCTAssertEqual(pill.id, nots.requestDuePillNotificationCallArgs[0].id)
    }

    func testSave_reflectsTabs() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.save()
        let tabs = viewModel.tabs as! MockTabs
        XCTAssertEqual(1, tabs.reflectPillsCallCount)
    }

    func testHandleIfUnsaved_whenUnsaved_presentsAlert() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.lastTaken = Date()
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        let alerts = viewModel.alerts! as! MockAlertFactory
        if alerts.createUnsavedAlertCallArgs.count <= 0 {
            XCTFail("Something might not be registering as change that needs to save.")
            return
        }
        let callArgs = alerts.createUnsavedAlertCallArgs[0]
        let returnValue = alerts.createUnsavedAlertReturnValue
        XCTAssertEqual(testViewController, callArgs.0)
        XCTAssertEqual(1, returnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenUnsaved_presentsAlertWithSaveHandlerThatSavesAndContinues() {
        let pill = setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.lastTaken = Date()
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        let alerts = viewModel.alerts! as! MockAlertFactory
        if alerts.createUnsavedAlertCallArgs.count <= 0 {
            XCTFail("Something might not be registering as change that needs to save.")
            return
        }
        let callArgs = alerts.createUnsavedAlertCallArgs[0]
        let returnValue = alerts.createUnsavedAlertReturnValue
        let handler = callArgs.1
        handler()
        XCTAssertEqual(pill.id, (viewModel.sdk?.pills as! MockPillSchedule).setIdCallArgs[0].0)
        XCTAssertEqual(1, returnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenUnsaved_presentsAlertWithDiscardHandlerThatResetsSelections() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.lastTaken = Date()
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        let alerts = viewModel.alerts! as! MockAlertFactory

        if alerts.createUnsavedAlertCallArgs.count <= 0 {
            XCTFail("Likely not catching something that needs to save")
            return
        }

        let callArgs = alerts.createUnsavedAlertCallArgs[0]
        let returnValue = alerts.createUnsavedAlertReturnValue
        let handler = callArgs.2
        handler()

        // Test that it resets what was selected at beginning of test
        XCTAssertNil(viewModel.selections.lastTaken)
        XCTAssertEqual(1, returnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenDiscardingNewPill_deletesPill() {
        let expectedIndex = 2
        setupPill()
        let pills = dependencies.sdk!.pills as! MockPillSchedule
        let testPill = MockPill()
        testPill.name = PillStrings.NewPill
        pills.all = [MockPill(), MockPill(), testPill]
        let viewModel = PillDetailViewModel(expectedIndex, dependencies: dependencies)
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        let alerts = viewModel.alerts! as! MockAlertFactory
        if alerts.createUnsavedAlertCallArgs.count <= 0 {
            XCTFail("The alert was not created.")
            return
        }
        let discard = alerts.createUnsavedAlertCallArgs[0].2
        discard()
        let actual = pills.deleteCallArgs[0]
        XCTAssertEqual(expectedIndex, actual)
        XCTAssertEqual(1, alerts.createUnsavedAlertReturnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenNothingSelected_popsNavigationWithoutAlertChoice() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let nav = dependencies.nav as! MockNav
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        if nav.popCallArgs.count <= 0 {
            XCTFail("Pill changes were falsely registered. An alert awaits a response.")
            return
        }
        XCTAssertEqual(testViewController, nav.popCallArgs[0])
    }

    func testSelectName_selectsExpectedName() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selectName(0)
        XCTAssertEqual(PillStrings.DefaultPills[0], viewModel.selections.name)
        viewModel.selectName(1)
        XCTAssertEqual(PillStrings.DefaultPills[1], viewModel.selections.name)
        viewModel.selectName(2)
        XCTAssertEqual(PillStrings.ExtraPills[0], viewModel.selections.name)
        viewModel.selectName(3)
        XCTAssertEqual(PillStrings.ExtraPills[1], viewModel.selections.name)
    }

    func testSelectExpirationIntervalFromRow_selectsExpectedInterval() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let getActual = { viewModel.selections.expirationIntervalSetting }
        viewModel.selectExpirationInterval(0)
        XCTAssertEqual(.EveryDay, getActual())
        viewModel.selectExpirationInterval(1)
        XCTAssertEqual(.EveryOtherDay, getActual())
        viewModel.selectExpirationInterval(2)
        XCTAssertEqual(.FirstXDays, getActual())
        viewModel.selectExpirationInterval(3)
        XCTAssertEqual(.LastXDays, getActual())
        viewModel.selectExpirationInterval(4)
        XCTAssertEqual(.XDaysOnXDaysOff, getActual())
        viewModel.selectExpirationInterval(5)
    }

    func testSelectExpirationInterval_whenRowOutsideRange_usesEveryDay() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationIntervalSetting = .FirstXDays
        viewModel.selectExpirationInterval(-1)
        let actual = viewModel.selections.expirationIntervalSetting
        XCTAssertEqual(.EveryDay, actual)
    }

    func testEnableOrDisable_whenGivenUnevenLists_doesNotChangePickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel()]
        let pill = setupPill()
        pill.times = []
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00"
        viewModel.enableOrDisable(pickers, labels)
        // defaults to enabled
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertTrue(pickers[1].isEnabled)
        XCTAssertTrue(pickers[2].isEnabled)
        XCTAssertTrue(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertTrue(labels[1].isEnabled)
    }

    func testEnableOrDisable_whenTimesadayZero_doesNotChangePickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
        let pill = setupPill()
        pill.times = []
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.enableOrDisable(pickers, labels)
        // defaults to enabled
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertTrue(pickers[1].isEnabled)
        XCTAssertTrue(pickers[2].isEnabled)
        XCTAssertTrue(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertTrue(labels[1].isEnabled)
        XCTAssertTrue(labels[2].isEnabled)
        XCTAssertTrue(labels[3].isEnabled)
    }

    func testEnableOrDisable_whenTimesadayOne_enablesOrDisablesExpectedPickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00"
        viewModel.enableOrDisable(pickers, labels)
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertFalse(pickers[1].isEnabled)
        XCTAssertFalse(pickers[2].isEnabled)
        XCTAssertFalse(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertFalse(labels[1].isEnabled)
        XCTAssertFalse(labels[2].isEnabled)
        XCTAssertFalse(labels[3].isEnabled)
    }

    func testEnableOrDisable_whenTimesadayTwo_enablesOrDisablesExpectedPickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00,1:00:00"
        viewModel.enableOrDisable(pickers, labels)
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertTrue(pickers[1].isEnabled)
        XCTAssertFalse(pickers[2].isEnabled)
        XCTAssertFalse(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertTrue(labels[1].isEnabled)
        XCTAssertFalse(labels[2].isEnabled)
        XCTAssertFalse(labels[3].isEnabled)
    }

    func testEnableOrDisable_whenTimesadayThree_enablesOrDisablesExpectedPickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00,1:00:00,2:00:00"
        viewModel.enableOrDisable(pickers, labels)
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertTrue(pickers[1].isEnabled)
        XCTAssertTrue(pickers[2].isEnabled)
        XCTAssertFalse(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertTrue(labels[1].isEnabled)
        XCTAssertTrue(labels[2].isEnabled)
        XCTAssertFalse(labels[3].isEnabled)
    }

    func testEnableOrDisable_whenTimesadayFour_enablesOrDisablesExpectedPickers() {
        let pickers = [UIDatePicker(), UIDatePicker(), UIDatePicker(), UIDatePicker()]
        let labels = [UILabel(), UILabel(), UILabel(), UILabel()]
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = "12:00:00,1:00:00,2:00:00,3:00:00"
        viewModel.enableOrDisable(pickers, labels)
        XCTAssertTrue(pickers[0].isEnabled)
        XCTAssertTrue(pickers[1].isEnabled)
        XCTAssertTrue(pickers[2].isEnabled)
        XCTAssertTrue(pickers[3].isEnabled)

        XCTAssertTrue(labels[0].isEnabled)
        XCTAssertTrue(labels[1].isEnabled)
        XCTAssertTrue(labels[2].isEnabled)
        XCTAssertTrue(labels[3].isEnabled)
    }
}
