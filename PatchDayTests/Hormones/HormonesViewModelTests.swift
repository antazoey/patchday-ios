//
//  HormonesViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/13/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class HormonesViewModelTests: XCTestCase {
	func testInit_callsReloadContext() {
		let table = UITableView()
		let style = UIUserInterfaceStyle.dark
		let deps = MockDependencies()
		let hormones = deps.sdk!.hormones as! MockHormoneSchedule
		_ = HormonesViewModel(hormonesTableView: table, style: style, dependencies: deps)
		let actual = hormones.reloadContextCallCount
		XCTAssertEqual(1, actual)
	}

	func testHandleRowTapped_whenChoosesChangeAction_callsAlertsPresentHormoneActionsWithExpectedIndex() {
		let table = UITableView()
		let style = UIUserInterfaceStyle.dark
		let deps = MockDependencies()
		let viewModel = HormonesViewModel(hormonesTableView: table, style: style, dependencies: deps)
		viewModel.handleRowTapped(at: 0, UIViewController(), reload: {})
		let alerts = deps.alerts! as! MockAlerts
		let alert = alerts.presentHormoneActionsCallArgs[0]
		XCTAssertEqual(0, alert.0)
	}
}
