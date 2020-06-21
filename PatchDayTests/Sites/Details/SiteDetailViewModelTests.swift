//
//  SiteDetailViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/5/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SiteDetailViewModelTests: XCTestCase {

	private var dependencies: MockDependencies! = nil
	private var siteImagePicker: SiteImagePicker! = nil

	private let picker = UIPickerView()
	private let imageView = UIImageView()
	private let saveButton = UIBarButtonItem()

	private var relatedViews: SiteImagePickerDelegateRelatedViews {
		SiteImagePickerDelegateRelatedViews(
			getPicker: { self.picker },
			getImageView: { self.imageView },
			getSaveButton: { self.saveButton }
		)
	}

	private func createImagePicker(selectedSiteIndex: Int=0) -> SiteImagePicker {
		let props = SiteImagePickerDelegateProperties(
			selectedSiteIndex: selectedSiteIndex,
			views: relatedViews
		)
		return SiteImagePicker(props: props)
	}

	@discardableResult
	private func setupSite(siteIndex: Index=0) -> MockSite {
		let site = MockSite()
		dependencies = MockDependencies()
		let schedule = dependencies.sdk?.sites as! MockSiteSchedule
		schedule.all = [MockSite(), site, MockSite()]
		schedule.names = ["Right Butt", "Left Butt", "Neck"]
		schedule.subscriptIndexReturnValue = site
		return site
	}

	func createViewModel(index: Index=0, sitePicker: SiteImagePicker?=nil) -> SiteDetailViewModel {
		siteImagePicker = sitePicker ?? createImagePicker()
		return SiteDetailViewModel(index, siteImagePicker, dependencies)
	}

	func testInitInitsPicker() {
		setupSite()
		let viewModel = createViewModel()
		XCTAssertNotNil(viewModel.imagePickerDelegate)
	}

	func testInitSelectCorrectStartIndexOfSiteImagePicker() {
		setupSite()
		let imgParams = SiteImageDeterminationParameters(
			imageId: SiteStrings.LeftQuad, deliveryMethod: .Injections
		)
		let ctorParams = SiteDetailViewModelConstructorParams(0, imgParams, relatedViews)
		let viewModel = SiteDetailViewModel(ctorParams)
		let expected = SiteImages.injectionImages.firstIndex {
			$0.accessibilityIdentifier == SiteStrings.LeftQuad
		}
		let actual = viewModel.imagePickerDelegate?._props.selectedImageIndex
		XCTAssertEqual(expected, actual)
	}

	func testSiteNamePickerStartIndex_whenNoNameSelected_returnsIndexOfSiteSiteName() {
		let site = setupSite()
		site.name = "Neck"  // index 2
		let viewModel = createViewModel()
		XCTAssertEqual(2, viewModel.siteNamePickerStartIndex)
	}

	func testSiteNamePickerStartIndex_whenNameSelected_returnsIndexOfSelected() {
		let site = setupSite()
		site.name = "Neck"  // index 2
		let viewModel = createViewModel()
		viewModel.selections.selectedSiteName = "Left Butt"  // index 1
		XCTAssertEqual(1, viewModel.siteNamePickerStartIndex)
	}

	func testSiteImage_returnsExpectedImage() {
		let site = setupSite()
		site.imageId = SiteStrings.Arms
		let viewModel = createViewModel()
		(viewModel.sdk?.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
		XCTAssertEqual(SiteImages.arms, viewModel.siteImage)
	}


	func testHandleSave_whenImageDoesNotExist_doesNotSave() {
		setupSite()
		let viewModel = createViewModel()
		siteImagePicker._props.selectedImageIndex = 50
		viewModel.selections.selectedSiteName = nil
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let callArgs = (viewModel.sdk?.sites as! MockSiteSchedule).setImageIdCallArgs
		XCTAssertEqual(0, callArgs.count)
	}

	func testHandleSave_whenImageExistsAndSelected_saves() {
		let site = setupSite()
		site.name = SiteStrings.Arms
		site.imageId = SiteStrings.Arms
		let viewModel = createViewModel()
		(viewModel.sdk?.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
		siteImagePicker._props.selectedImageIndex = 0
		viewModel.selections.selectedSiteName = nil
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let callArgs = (viewModel.sdk?.sites as! MockSiteSchedule).setImageIdCallArgs
		let siteIndex = 0
		XCTAssertEqual(siteIndex, callArgs[0].0)
		XCTAssertEqual("Right Glute", callArgs[0].1)
	}

	func testHandleSave_whenGivenNil_doesNotSave() {
		setupSite()
		let viewModel = createViewModel()
		viewModel.selections.selectedSiteName = nil
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let sites = viewModel.sdk?.sites as! MockSiteSchedule
		let renameCallArgs = sites.renameCallArgs
		let insertNewCallArgs = sites.insertNewCallArgs
		XCTAssertEqual(0, renameCallArgs.count)
		XCTAssertEqual(0, insertNewCallArgs.count)
	}

	func testHandleSave_whenIndexOutOfRange_doesNotSave() {
		setupSite()
		let viewModel = createViewModel(index: 5)
		let sites = viewModel.sdk?.sites as! MockSiteSchedule
		sites.count = 0  // Out of range because of this
		viewModel.selections.selectedSiteName = "New Name"
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let renameCallArgs = sites.renameCallArgs
		let insertNewCallArgs = sites.insertNewCallArgs
		XCTAssertEqual(0, renameCallArgs.count)
		XCTAssertEqual(0, insertNewCallArgs.count)
	}

	func testHandleSave_whenGivenNameAndSiteIndexExists_savesByRenaming() {
		setupSite()
		let viewModel = createViewModel()
		let sites = viewModel.sdk?.sites as! MockSiteSchedule
		sites.count = 5
		viewModel.selections.selectedSiteName = "New Name"
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let renameCallArgs = sites.renameCallArgs
		let insertNewCallArgs = sites.insertNewCallArgs
		XCTAssertEqual(0, renameCallArgs[0].0)
		XCTAssertEqual("New Name", renameCallArgs[0].1)
		XCTAssertEqual(0, insertNewCallArgs.count)
	}

	func testHandleSave_whenGivenNameAndSiteIndexEqualsCount_savesByInsertingNew() {
		setupSite()
		let viewModel = createViewModel(index: 5)
		let sites = viewModel.sdk?.sites as! MockSiteSchedule
		sites.count = 5  // Equal to site.order above
		viewModel.selections.selectedSiteName = "New Name"
		viewModel.handleSave(siteDetailViewController: UIViewController())
		let renameCallArgs = sites.renameCallArgs
		let insertNewCallArgs = sites.insertNewCallArgs
		XCTAssertEqual(0, renameCallArgs.count)
		XCTAssertEqual("New Name", insertNewCallArgs[0].0)
		XCTAssertNil(insertNewCallArgs[0].1)
	}

	func testHandleSave_resetsSelections() {
		setupSite()
		let viewModel = createViewModel(index: 0)
		viewModel.selections.selectedSiteName = "TEST SITE NAME"
		viewModel.handleSave(siteDetailViewController: UIViewController())
		XCTAssertNil(viewModel.selections.selectedSiteName)
	}

	func testHandleIfUnsaved_whenDiscardingFromNewSite_deletesNewSite() {
		let site = setupSite()
		site.order = 5
		site.name = SiteStrings.NewSite
		let viewModel = createViewModel(index: site.order)
		let sites = viewModel.sdk?.sites as! MockSiteSchedule
		sites.count = 5  // Equal to site.order above
		viewModel.handleIfUnsaved(UIViewController())
		let discard = (viewModel.alerts as! MockAlerts).presentUnsavedAlertCallArgs[0].2
		discard()
		let actual = (viewModel.sdk!.sites as! MockSiteSchedule).deleteCallArgs[0]
		XCTAssertEqual(site.order, actual)
	}

	func testHandleIfUnsaved_whenNoSelections_stillPops() {
		setupSite()
		let viewModel = createViewModel(index: 0)
		let vc = UIViewController()
		viewModel.handleIfUnsaved(vc)
		let nav = viewModel.nav as! MockNav
		XCTAssertEqual(vc, nav.popCallArgs[0])
	}

	func testGetAttributedSiteName_hasExpectedName() {
		setupSite()
		let viewModel = createViewModel(index: 5)
		XCTAssertEqual("Right Butt", viewModel.getAttributedSiteName(at: 0)!.string)
		XCTAssertEqual("Left Butt", viewModel.getAttributedSiteName(at: 1)!.string)
		XCTAssertEqual("Neck", viewModel.getAttributedSiteName(at: 2)!.string)
	}
}
