//
//  SitesViewModelTests.swift
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

class SitesViewModelTests: XCTestCase {
	func testReorderSites_callsReorderSites() {
		let table = UITableView()
		let dep = MockDependencies()
		let sites = dep.sdk?.sites as! MockSiteSchedule
		let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
		let source = 0
		let dest = 3
		viewModel.reorderSites(sourceRow: source, destinationRow: dest)
		let actualSource = sites.reorderCallArgs[0].0
		let actualDest = sites.reorderCallArgs[0].1
		XCTAssertEqual(source, actualSource)
		XCTAssertEqual(dest, actualDest)
	}

	func testReorderSites_updatesSiteIndexToDestination() {
		let table = UITableView()
		let dep = MockDependencies()
		let settings = dep.sdk!.settings as! MockSettings
		let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
		let dest = 3
		viewModel.reorderSites(sourceRow: 0, destinationRow: dest)
		let actualDest = settings.setSiteIndexCallArgs[0]
		XCTAssertEqual(dest, actualDest)
	}
}
