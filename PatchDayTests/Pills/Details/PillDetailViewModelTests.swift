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

    func testExpirationIntervalPickerStartIndex_usesSelectedInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        let actual = viewModel.expirationIntervalStartIndex
        XCTAssertEqual(1, actual)
    }

    func testExpirationIntervalPickerStartIndex_whenNothingSelected_usesPillInterval() {
        let pill = setupPill()
        pill.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        viewModel.selections.name = nil
        let actual = viewModel.expirationIntervalStartIndex
        XCTAssertEqual(2, actual)
    }

    func testTimesaday_whenNothingSelected_returnsPillTimesaday() {
        let pill = setupPill()
        let times = [Time()]
        pill.times = times
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(times.count, viewModel.timesaday)
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
        let expectedTimes = [times[0], newTime, newTime]
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
        XCTAssertEqual(times.count, viewModel.times.count)
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

    func testGetPickerTimes_returnsExpectedTimes() {
        let pill = setupPill()
        let now = Date()
        pill.times = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!
        ]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let times = viewModel.getPickerTimes(timeIndex: 1)
        XCTAssertEqual(pill.times[0], times.min)
        XCTAssertEqual(pill.times[1], times.start)
    }

    func testGetPickerTimes_whenGiveIndexZero_returnsExpectedTimesWithNilMin() {
        let pill = setupPill()
        let now = Date()
        pill.times = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!
        ]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let times = viewModel.getPickerTimes(timeIndex: 0)
        XCTAssertNil(times.min)
        XCTAssertEqual(pill.times[0], times.start)
    }

    func testGetPickerTimes_whenMinDateIsOutOfOrder_returnsExpectedTimesWithMinEqualToStart() {
        let pill = setupPill()
        let now = Date()
        let t1 = Calendar.current.date(bySettingHour: 12, minute: 9, second: 9, of: now)!
        let t2 = Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!
        let t3 = Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!
        pill.times = [t1, t2, t3]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let times = viewModel.getPickerTimes(timeIndex: 1)
        XCTAssert(PDTest.sameTime(t2, times.min!))
        XCTAssert(PDTest.sameTime(t3, times.start))
    }

    func testGetPickerTimes_whenLastPickerDate_worksAsExpected() {
        let pill = setupPill()
        let now = Date()
        pill.times = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!,
            Calendar.current.date(bySettingHour: 12, minute: 12, second: 12, of: now)!
        ]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let times = viewModel.getPickerTimes(timeIndex: 3)
        XCTAssert(PDTest.sameTime(pill.times[2], times.min!))
        XCTAssert(PDTest.sameTime(pill.times[3], times.start))
    }

    func testGetPickerTimes_usesSelections() {
        let pill = setupPill()
        let now = Date()
        pill.times = [
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 11, second: 11, of: now)!,
            Calendar.current.date(bySettingHour: 12, minute: 12, second: 12, of: now)!
        ]
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.times = PDDateFormatter.convertDatesToCommaSeparatedString([
            Calendar.current.date(bySettingHour: 9, minute: 9, second: 9, of: now)!,
            Calendar.current.date(bySettingHour: 10, minute: 10, second: 10, of: now)!,
            Calendar.current.date(bySettingHour: 11, minute: 30, second: 30, of: now)!,
            Calendar.current.date(bySettingHour: 12, minute: 12, second: 12, of: now)!
        ])
        let actualTimes = viewModel.getPickerTimes(timeIndex: 3)
        let expectedTimes = DateFactory.createTimesFromCommaSeparatedString(
            viewModel.selections.times!
        )
        XCTAssert(PDTest.sameTime(expectedTimes[2], actualTimes.min!))
        XCTAssert(PDTest.sameTime(expectedTimes[3], actualTimes.start))
    }

    func testNotifyStartValue_whenNotifySelected_returnsNotify() {
        let pill = setupPill()
        pill.notify = false
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.notify = true
        XCTAssert(viewModel.notifyStartValue)
    }

    func testNotifyStartValue_whenNotifyNotSelected_returnsPillValue() {
        let pill = setupPill()
        pill.notify = false
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        viewModel.selections.notify = nil
        XCTAssertFalse(viewModel.notifyStartValue)
    }

    func testTitle_whenIsNewPill_returnsExpectedTitle() {
        let pill = setupPill()
        pill.isNew = true
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(PDTitleStrings.NewPillTitle, viewModel.title)
    }

    func testTitle_whenIsNotNewPill_returnsExpectedTitle() {
        let pill = setupPill()
        pill.name = "Spiro"
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        XCTAssertEqual(PDTitleStrings.EditPillTitle, viewModel.title)
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
        XCTAssertFalse(viewModel.selections.anyAttributeExists)
    }

    func testSave_callsSetPillWithSelections() {
        let pill = setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let name = "Test"
        let time = PDDateFormatter.convertDatesToCommaSeparatedString([Time()])
        let notify = true
        let interval = PillExpirationInterval.EveryDay.rawValue
        viewModel.selections.name = name
        viewModel.selections.times = time
        viewModel.selections.notify = notify
        viewModel.selections.expirationInterval = interval
        viewModel.save()
        let pills = (viewModel.sdk?.pills as! MockPillSchedule)
        XCTAssertEqual(pills.setIdCallArgs[0].0, pill.id)
        XCTAssertEqual(name, pills.setIdCallArgs[0].1.name)
        XCTAssertEqual(time, pills.setIdCallArgs[0].1.times)
        XCTAssertEqual(notify, pills.setIdCallArgs[0].1.notify)
        XCTAssertEqual(interval, pills.setIdCallArgs[0].1.expirationInterval)
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
        XCTAssertEqual(1, alerts.createUnsavedAlertCallArgs.count)
        let discard = alerts.createUnsavedAlertCallArgs[0].2
        discard()
        let actual = pills.deleteCallArgs[0]
        XCTAssertEqual(expectedIndex, actual)
        XCTAssertEqual(1, alerts.createUnsavedAlertReturnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenNothingSelected_stillPops() {
        setupPill()
        let viewModel = PillDetailViewModel(0, dependencies: dependencies)
        let nav = dependencies.nav as! MockNav
        let testViewController = UIViewController()
        viewModel.handleIfUnsaved(testViewController)
        XCTAssertEqual(testViewController, nav.popCallArgs[0])
    }
}
