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

    func testInit_callsReloadContext() {
        let table = UITableView()
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        _ = SitesViewModel(sitesTableView: table, dependencies: dep)
        XCTAssertEqual(1, sites.reloadContextCallCount)
    }

    func testSites_returnsExpectedSites() {
        let table = UITableView()
        let dep = MockDependencies()
        let mockSite = MockSite()
        (dep.sdk!.sites as! MockSiteSchedule).all = [mockSite]
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        let expectedSiteId = mockSite.id
        let actualSiteSchedule = viewModel.sites as! MockSiteSchedule
        let actualSites = actualSiteSchedule.all
        let actualSite = actualSites[0]
        let actualSiteId = actualSite.id
        XCTAssertEqual(expectedSiteId, actualSiteId)
        XCTAssertEqual(1, actualSites.count)
    }

    func testSitesCount_whenNilSdk_returnsZero() {
        let table = UITableView()
        let dep = MockDependencies()
        dep.sdk = nil
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        XCTAssertEqual(0, viewModel.sitesCount)
    }


    func testSitesCount_returnsSiteCount() {
        let table = UITableView()
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite()]
        let expectedCount = sites.count
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        XCTAssertEqual(expectedCount, viewModel.sitesCount)
    }

    func testSiteOptionsCount_whenNilSdk_returnsZero() {
        let table = UITableView()
        let dep = MockDependencies()
        dep.sdk = nil
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        XCTAssertEqual(0, viewModel.sitesOptionsCount)
    }

    func testSiteOptionsCount_returnsNamesCount() {
        let table = UITableView()
        let dep = MockDependencies()
        (dep.sdk?.sites as! MockSiteSchedule).names = ["test", "orange", "foobar"]  // 3
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        XCTAssertEqual(3, viewModel.sitesOptionsCount)
    }

    func testCreateSiteCellSwipeActions_returnsGestureWithCorrectNumberOfActions() {
        let table = UITableView()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        let gesture = viewModel.createSiteCellSwipeActions(indexPath: IndexPath(index: 0))
        XCTAssertEqual(1, gesture.actions.count)
    }

    func testCreateSiteCellSwipeActions_returnsRedActionButton() {
        let table = UITableView()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTableView: table, dependencies: dep)
        let gesture = viewModel.createSiteCellSwipeActions(indexPath: IndexPath(index: 0))
        let action = gesture.actions[0]
        let expected = UIColor.red
        let actual = action.backgroundColor
        XCTAssertEqual(expected, actual)
    }

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
