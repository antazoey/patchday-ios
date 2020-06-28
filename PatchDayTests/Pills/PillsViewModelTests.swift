//
//  PillsViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillsViewModelTests: XCTestCase {

	private let tableView = UITableView()

	func testPresentPillActions_whenChooseTake_callsCompleter() {
		let alertFactory = MockAlertFactory()
		let deps = MockDependencies()
		(deps.sdk?.pills as! MockPillSchedule).all = [MockPill()]
		let viewModel = PillsViewModel(
			pillsTableView: self.tableView, alertFactory: alertFactory, dependencies: deps
		)
		var completerCalled = false
		let completer = { completerCalled = true }
		viewModel.presentPillActions(
			at: 0,
			viewController: UIViewController(),
			takePillCompletion: completer
		)
		let handlers = alertFactory.createPillActionsCallArgs[0].1
		handlers.takePill()
		XCTAssert(completerCalled)
	}
}
