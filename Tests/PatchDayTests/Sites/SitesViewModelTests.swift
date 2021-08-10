//
//  SitesViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/13/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SitesViewModelTests: PDTestCase {

    func testInit_callsReloadContext() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        _ = SitesViewModel(sitesTable: table, dependencies: dep)
        XCTAssertEqual(1, sites.reloadContextCallCount)
    }

    func testSites_returnsExpectedSites() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let mockSite = MockSite()
        (dep.sdk!.sites as! MockSiteSchedule).all = [mockSite]
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let expectedSiteId = mockSite.id
        let actualSiteSchedule = viewModel.sites as! MockSiteSchedule
        let actualSites = actualSiteSchedule.all
        let actualSite = actualSites[0]
        let actualSiteId = actualSite.id
        XCTAssertEqual(expectedSiteId, actualSiteId)
        PDAssertSingle(actualSites)
    }

    func testSitesCount_whenNilSdk_returnsZero() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        dep.sdk = nil
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        XCTAssertEqual(0, viewModel.sitesCount)
    }

    func testSitesCount_returnsSiteCount() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite()]
        let expectedCount = sites.count
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        XCTAssertEqual(expectedCount, viewModel.sitesCount)
    }

    func testSiteOptionsCount_whenNilSdk_returnsZero() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        dep.sdk = nil
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        XCTAssertEqual(0, viewModel.sitesOptionsCount)
    }

    func testSiteOptionsCount_returnsNamesCount() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        (dep.sdk?.sites as! MockSiteSchedule).names = ["test", "orange", "foobar"]  // 3
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        XCTAssertEqual(3, viewModel.sitesOptionsCount)
    }

    func testCreateSiteCellSwipeActions_returnsGestureWithCorrectNumberOfActions() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let gesture = viewModel.createSiteCellSwipeActions(indexPath: IndexPath(index: 0))
        PDAssertSingle(gesture.actions)
    }

    func testCreateSiteCellSwipeActions_returnsRedActionButton() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let gesture = viewModel.createSiteCellSwipeActions(indexPath: IndexPath(index: 0))
        let action = gesture.actions[0]
        let expected = UIColor.red
        let actual = action.backgroundColor
        XCTAssertEqual(expected, actual)
    }

    func testIsValidSiteIndex_whenNilSdk_returnsFalse() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        XCTAssertFalse(viewModel.isValidSiteIndex(0))
    }

    func testIsValidSiteIndex_whenSubscriptReturnsNil_returnsFalse() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        let sites = deps.sdk!.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = nil
        XCTAssertFalse(viewModel.isValidSiteIndex(0))
    }

    func testIsValidSiteIndex_whenSubscriptReturnsSite_returnsTrue() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        let sites = deps.sdk!.sites as! MockSiteSchedule
        sites.subscriptIndexReturnValue = MockSite()
        XCTAssertTrue(viewModel.isValidSiteIndex(0))
    }

    func testIsValidSiteIndex_whenNegativeIndex_returnsFalse() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        XCTAssertFalse(viewModel.isValidSiteIndex(-1))
    }

    func testResetSites_whenNilSdk_doesNotReset() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        let sites = deps.sdk!.sites as! MockSiteSchedule
        deps.sdk = nil
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        viewModel.resetSites()
        XCTAssertEqual(0, sites.resetCallCount)
    }

    func testResetSites_resets() {
        let table = MockSitesTable()
        let deps = MockDependencies()
        let sites = deps.sdk!.sites as! MockSiteSchedule
        let viewModel = SitesViewModel(sitesTable: table, dependencies: deps)
        viewModel.resetSites()
        XCTAssertEqual(1, sites.resetCallCount)
    }

    func testReorderSites_callsReorderSites() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let source = 0
        let dest = 3
        viewModel.reorderSites(sourceRow: source, destinationRow: dest)
        let actualSource = sites.reorderCallArgs[0].0
        let actualDest = sites.reorderCallArgs[0].1
        XCTAssertEqual(source, actualSource)
        XCTAssertEqual(dest, actualDest)
    }

    func testReorderSites_updatesSiteIndexToDestination() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let settings = dep.sdk!.settings as! MockSettings
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let dest = 3
        viewModel.reorderSites(sourceRow: 0, destinationRow: dest)
        let actualDest = settings.setSiteIndexCallArgs[0]
        XCTAssertEqual(dest, actualDest)
    }

    func testReorderSites_reloadsTable() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let dest = 3
        viewModel.reorderSites(sourceRow: 0, destinationRow: dest)
        XCTAssertEqual(1, table.reloadDataCallCount)
    }

    func testGoToSiteDetails_ifInEditingMode_turnsOffEditingMode() {
        let table = MockSitesTable()
        table.isEditing = true
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.goToSiteDetails(siteIndex: 0, sitesViewController: UIViewController())
        XCTAssertFalse(table.toggleEditCallArgs[0])
    }

    func testGoToSiteDetails_ifNotInEditingMode_doesNotTurnOffEditingMode() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.goToSiteDetails(siteIndex: 0, sitesViewController: UIViewController())
        PDAssertEmpty(table.toggleEditCallArgs)
    }

    func testGoToSiteDetails_setsBarBackItem() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let viewController = UIViewController()
        viewModel.goToSiteDetails(siteIndex: 0, sitesViewController: viewController)
        XCTAssertEqual(PDTitleStrings.SitesTitle, viewController.navigationItem.backBarButtonItem?.title)
    }

    func testGoToSiteDetails_navigates() {
        let table = MockSitesTable()
        let dep = MockDependencies()
        let settings = dep.sdk?.settings as! MockSettings
        let nav = dep.nav as! MockNav
        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let viewController = UIViewController()
        let deliveyMethod = DeliveryMethodUD(.Gel)
        let testSite = MockSite()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        let testIndex = 1
        let imageId = SiteStrings.LeftArm
        testSite.imageId = imageId
        sites.all = [MockSite(), testSite, MockSite()]
        sites.subscriptIndexReturnValue = testSite
        settings.deliveryMethod = deliveyMethod

        viewModel.goToSiteDetails(siteIndex: testIndex, sitesViewController: viewController)

        let callArgs = nav.goToSiteDetailsCallArgs
        PDAssertSingle(callArgs)
        let actualIndex = callArgs[0].0
        let actualVc = callArgs[0].1
        let params = callArgs[0].2
        XCTAssertEqual(testIndex, actualIndex)
        XCTAssertEqual(viewController, actualVc)
        XCTAssertEqual(.Gel, params.deliveryMethod)
        XCTAssertEqual(imageId, params.imageId)
    }

    func testHandleInsert_whenInsertFails_doesNotNavigate() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        let nav = dep.nav as! MockNav

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        sites.insertNewReturnValue = nil
        viewModel.handleSiteInsert(sitesViewController: UIViewController())

        let callArgs = nav.goToSiteDetailsCallArgs
        PDAssertEmpty(callArgs)
    }

    func testHandleInsert_whenInsertSucceeds_navigates() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        let nav = dep.nav as! MockNav
        sites.insertNewReturnValue = MockSite()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.handleSiteInsert(sitesViewController: UIViewController())

        let callArgs = nav.goToSiteDetailsCallArgs
        PDAssertSingle(callArgs)
    }

    func testHandleInsert_callsSdkInsertWithExpectedParameters() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule
        sites.insertNewReturnValue = MockSite()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.handleSiteInsert(sitesViewController: UIViewController())

        let callArgs = sites.insertNewCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(SiteStrings.NewSite, callArgs[0].0)
        XCTAssertNil(callArgs[0].1)
    }

    func testToggleEdit_whenEditing_callsToggleEditWithTrue() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.toggleEdit(true)

        let callArgs = table.toggleEditCallArgs
        PDAssertSingle(true, callArgs)
    }

    func testToggleEdit_whenNotEditing_callsToggleEditWithFalse() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.toggleEdit(false)

        let callArgs = table.toggleEditCallArgs
        PDAssertSingle(false, callArgs)
    }

    func testDeleteSite_deletesSite() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let sites = dep.sdk?.sites as! MockSiteSchedule

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        viewModel.deleteSite(at: IndexPath(row: 1, section: 0))

        let callArgs = sites.deleteCallArgs
        PDAssertSingle(1, callArgs)
    }

    func testDeleteSite_deletesCell() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let index = IndexPath(row: 1, section: 0)
        viewModel.deleteSite(at: index)

        let callArgs = table.deleteCellCallArgs
        PDAssertSingle(index, callArgs)
    }

    func testDeleteSite_reloadsTable() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let index = IndexPath(row: 1, section: 0)
        viewModel.deleteSite(at: index)

        XCTAssertEqual(1, table.reloadCellsCallCount)
    }

    @objc func mockInsert() { }
    @objc func mockEdit() { }
    func testCreateBarButtonItems_createsInsertButton() {
        let table = MockSitesTable()
        table.isEditing = false
        let dep = MockDependencies()
        let viewController = UIViewController()

        let viewModel = SitesViewModel(sitesTable: table, dependencies: dep)
        let items = viewModel.createBarItems(
            insertAction: #selector(mockInsert),
            editAction: #selector(mockEdit),
            sitesViewController: viewController
        )
        let insert = items[0]
        let edit = items[1]

        XCTAssertEqual(#selector(mockInsert), insert.action)
        XCTAssertEqual(viewController, insert.target as! UIViewController)
        XCTAssertEqual(PDColors[.NewItem], insert.tintColor)
        XCTAssertNil(insert.title)
        let dummy = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: UIViewController(),
            action: #selector(mockInsert)
        )
        XCTAssertEqual(dummy.image, insert.image)

        XCTAssertEqual(#selector(mockEdit), edit.action)
        XCTAssertEqual(viewController, edit.target as! UIViewController)
        XCTAssertEqual("Edit", edit.title)
    }
}
