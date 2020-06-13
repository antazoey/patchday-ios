//
//  PillDetailsTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/30/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

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
		let time1 = Time()
		let notify = true
		let interval = PillExpirationInterval.EveryDay.rawValue
		viewModel.selections.name = name
		viewModel.selections.time1 = time1
		viewModel.selections.notify = notify
		viewModel.selections.expirationInterval = interval
		viewModel.save()
		let pills = (viewModel.sdk?.pills as! MockPillSchedule)
		XCTAssertEqual(pills.setIdCallArgs[0].0, pill.id)
		XCTAssertEqual(name, pills.setIdCallArgs[0].1.name)
		XCTAssertEqual(time1, pills.setIdCallArgs[0].1.time1)
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
		XCTAssertEqual(1, tabs.reflectDuePillBadgeValueCallCount)
	}

	func testHandleIfUnsaved_whenUnsaved_presentsAlert() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.lastTaken = Date()
		let testViewController = UIViewController()
		viewModel.handleIfUnsaved(testViewController)
		let alerts = viewModel.alerts! as! MockAlerts
		let callArgs = alerts.presentUnsavedAlertCallArgs[0]
		XCTAssertEqual(testViewController, callArgs.0)
	}

	func testHandleIfUnsaved_whenUnsaved_presentsAlertWithSaveHandlerThatSavesAndContinues() {
		let pill = setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.lastTaken = Date()
		let testViewController = UIViewController()
		viewModel.handleIfUnsaved(testViewController)
		let alerts = viewModel.alerts! as! MockAlerts
		let callArgs = alerts.presentUnsavedAlertCallArgs[0]
		let handler = callArgs.1
		handler()
		XCTAssertEqual(pill.id, (viewModel.sdk?.pills as! MockPillSchedule).setIdCallArgs[0].0)
	}

	func testHandleIfUnsaved_whenUnsaved_presentsAlertWithDiscardHandlerThatResetsSelections() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.lastTaken = Date()
		let testViewController = UIViewController()
		viewModel.handleIfUnsaved(testViewController)
		let alerts = viewModel.alerts! as! MockAlerts
		let callArgs = alerts.presentUnsavedAlertCallArgs[0]
		let handler = callArgs.2
		handler()

		// Test that it resets what was selected at beginning of test
		XCTAssertNil(viewModel.selections.lastTaken)
	}

	func testHandleIfUnsaved_whenDiscardingNewPill_deletesPill() {
		let expectedIndex = 2
		setupPill()
		let pills = dependencies.sdk!.pills as! MockPillSchedule
		let testPill = MockPill()
		testPill.isNew = true
		pills.all = [MockPill(), MockPill(), testPill]
		let viewModel = PillDetailViewModel(expectedIndex, dependencies: dependencies)
		let testViewController = UIViewController()
		viewModel.handleIfUnsaved(testViewController)
		let discard = (viewModel.alerts! as! MockAlerts).presentUnsavedAlertCallArgs[0].2
		discard()
		let actual = pills.deleteCallArgs[0]
		XCTAssertEqual(expectedIndex, actual)
	}
}
