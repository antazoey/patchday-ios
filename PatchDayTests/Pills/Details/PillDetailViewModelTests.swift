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

	func testIsNewPill_whenNameIsNewPill_returnsTrue() {
		let pill = setupPill()
		pill.name = PillStrings.NewPill
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		XCTAssertTrue(viewModel.isNewPill)
	}

	func testIsNewPill_whenNameIsNotNewPill_returnsFalse() {
		let pill = setupPill()
		pill.name = "Spiro"
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		XCTAssertFalse(viewModel.isNewPill)
	}

	func testHasUnsavedChanges_whenUnsavedChanges_returnsTrue() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.name = "Test"
		XCTAssert(viewModel.hasUnsavedChanges)
	}

	func testHasUnsavedChanges_whenDoesNotHaveUnsavedChanges_returnsFalse() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		XCTAssertFalse(viewModel.hasUnsavedChanges)
	}

	func testSave_resetsPillAttributes() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.name = "Test"
		viewModel.save()
		XCTAssertNil(viewModel.selections.name)
	}

	func testSave_setsHasUnsavedChangesToFalse() {
		setupPill()
		let viewModel = PillDetailViewModel(0, dependencies: dependencies)
		viewModel.selections.name = "Test"
		viewModel.save()
		XCTAssertFalse(viewModel.hasUnsavedChanges)
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
}
