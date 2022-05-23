//
//  SiteDetailViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/5/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SiteDetailViewModelTests: PDTestCase {

    private var dependencies: MockDependencies! = nil
    private var siteImagePicker: SiteImagePicker! = nil

    private let picker = UIPickerView()
    private let imageView = UIImageView()
    private let saveButton = UIBarButtonItem()

    private var relatedViews: SiteImagePickerRelatedViews {
        SiteImagePickerRelatedViews(
            getPicker: { self.picker },
            getImageView: { self.imageView },
            getSaveButton: { self.saveButton }
        )
    }

    private func createImagePicker(selectedSiteIndex: Int=0) -> SiteImagePicker {
        let props = SiteImagePickerProperties(
            selectedSiteIndex: selectedSiteIndex,
            imageChoices: SiteImages.patchImages,
            views: relatedViews,
            selectedImageIndex: 0
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
        if dependencies == nil {
            setupSite()
        }
        siteImagePicker = sitePicker ?? createImagePicker()
        return SiteDetailViewModel(index, siteImagePicker, dependencies)
    }

    func testInitInitsPicker() {
        let viewModel = createViewModel()
        XCTAssertNotNil(viewModel.imagePicker)
    }

    func testInitSelectsCorrectStartIndexOfSiteImagePicker() {
        let imageParameters = SiteImageDeterminationParameters(
            imageId: SiteStrings.LeftQuad, deliveryMethod: .Injections
        )
        let ctorParams = SiteDetailViewModelConstructorParams(0, imageParameters, relatedViews)
        let viewModel = SiteDetailViewModel(ctorParams)
        let expected = SiteImages.injectionImages.firstIndex {
            $0.accessibilityIdentifier == SiteStrings.LeftQuad
        }
        let actual = viewModel.imagePicker?._props.selectedImageIndex
        XCTAssertEqual(expected, actual)
    }

    func testSiteNameOptions_includesCustomSites() {
        let viewModel = createViewModel()
        XCTAssert(viewModel.siteNameOptions.contains("Neck"))
    }

    func testSiteNamePickerStartIndex_whenNoNameSelected_returnsIndexOfSiteSiteName() {
        let site = setupSite()
        site.name = "Neck"  // index 2
        let viewModel = createViewModel()
        XCTAssertEqual(6, viewModel.siteNamePickerStartIndex)
    }

    func testSiteNamePickerStartIndex_whenNameSelected_returnsIndexOfSelected() {
        let site = setupSite()
        site.name = "Neck"  // index 2
        let viewModel = createViewModel()
        viewModel.selections.selectedSiteName = "Left Butt"  // index 1
        XCTAssertEqual(2, viewModel.siteNamePickerStartIndex)
    }

    func testSiteImage_returnsExpectedImage() {
        let site = setupSite()
        site.imageId = SiteStrings.Arms
        let viewModel = createViewModel()
        (viewModel.sdk?.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
        XCTAssertEqual(SiteImages.arms, viewModel.siteImage)
    }

    func testSelectSite_selectsSite() {
        let viewModel = createViewModel()
        viewModel.selectSite(SiteStrings.LeftGlute)
        XCTAssertEqual(viewModel.selections.selectedSiteName, SiteStrings.LeftGlute)
    }

    func testSelectSite_whenSelectingTheExistingSite_doesNotChangeSiteImage() {
        let site = setupSite()
        let picker = createImagePicker()
        site.imageId = "Custom"
        picker.selectImage(row: 4)
        site.name = SiteStrings.LeftGlute
        let viewModel = createViewModel()
        viewModel.selectSite(SiteStrings.LeftGlute)
        XCTAssertEqual(4, picker.selectedRow)
    }

    func testSelectSite_whenSelectingNewExistingSite_selectsSiteImage() {
        let site = setupSite()
        let picker = createImagePicker()
        site.imageId = "Custom"
        picker.selectImage(row: 4)
        site.name = "Custom"
        let viewModel = createViewModel()
        viewModel.selectSite(SiteStrings.LeftGlute)
        XCTAssertEqual(imageView.image, SiteImages.patchLeftGlute)
    }

    func testSelectSite_whenSelectingUnknownSite_usesCustomDefaultImage() {
        let site = setupSite()
        let picker = createImagePicker()
        site.imageId = SiteStrings.LeftGlute
        picker.selectImage(row: 0)
        site.name = SiteStrings.LeftGlute
        let viewModel = createViewModel()
        viewModel.selectSite("Custom")
        XCTAssertEqual(imageView.image, SiteImages.customPatch)
    }

    func testHandleSave_whenImageDoesNotExist_doesNotSave() {
        let viewModel = createViewModel()
        siteImagePicker._props.selectedImageIndex = 50
        viewModel.selections.selectedSiteName = nil
        viewModel.handleSave(siteDetailViewController: UIViewController())
        let callArgs = (viewModel.sdk?.sites as! MockSiteSchedule).setImageIdCallArgs
        PDAssertEmpty(callArgs)
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
        let viewModel = createViewModel()
        viewModel.selections.selectedSiteName = nil
        viewModel.handleSave(siteDetailViewController: UIViewController())
        let sites = viewModel.sdk?.sites as! MockSiteSchedule
        let renameCallArgs = sites.renameCallArgs
        let insertNewCallArgs = sites.insertNewCallArgs
        PDAssertEmpty(renameCallArgs)
        PDAssertEmpty(insertNewCallArgs)
    }

    func testHandleSave_whenIndexOutOfRange_doesNotSave() {
        let viewModel = createViewModel(index: 5)
        let sites = viewModel.sdk?.sites as! MockSiteSchedule
        sites.all = []
        viewModel.selections.selectedSiteName = "New Name"
        viewModel.handleSave(siteDetailViewController: UIViewController())
        let renameCallArgs = sites.renameCallArgs
        let insertNewCallArgs = sites.insertNewCallArgs
        PDAssertEmpty(renameCallArgs)
        PDAssertEmpty(insertNewCallArgs)
    }

    func testHandleSave_whenGivenNameAndSiteIndexExists_savesByRenaming() {
        let viewModel = createViewModel()
        let sites = viewModel.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite(), MockSite()]
        viewModel.selections.selectedSiteName = "New Name"
        viewModel.handleSave(siteDetailViewController: UIViewController())
        let renameCallArgs = sites.renameCallArgs
        let insertNewCallArgs = sites.insertNewCallArgs
        XCTAssertEqual(0, renameCallArgs[0].0)
        XCTAssertEqual("New Name", renameCallArgs[0].1)
        PDAssertEmpty(insertNewCallArgs)
    }

    func testHandleSave_whenGivenNameAndSiteIndexEqualsCount_savesByInsertingNew() {
        let viewModel = createViewModel(index: 5)
        let sites = viewModel.sdk?.sites as! MockSiteSchedule
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite(), MockSite()]
        viewModel.selections.selectedSiteName = "New Name"
        viewModel.handleSave(siteDetailViewController: UIViewController())
        let renameCallArgs = sites.renameCallArgs
        let insertNewCallArgs = sites.insertNewCallArgs
        PDAssertEmpty(renameCallArgs)
        XCTAssertEqual("New Name", insertNewCallArgs[0].0)
        XCTAssertNil(insertNewCallArgs[0].1)
    }

    func testHandleSave_resetsSelections() {
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
        sites.all = [MockSite(), MockSite(), MockSite(), MockSite(), MockSite()]
        viewModel.handleIfUnsaved(UIViewController())
        let alerts = viewModel.alerts as! MockAlertFactory
        let discard = alerts.createUnsavedAlertCallArgs[0].2
        discard()
        let actual = (viewModel.sdk!.sites as! MockSiteSchedule).deleteCallArgs[0]
        XCTAssertEqual(site.order, actual)
        XCTAssertEqual(1, alerts.createUnsavedAlertReturnValue.presentCallCount)
    }

    func testHandleIfUnsaved_whenNoSelections_stillPops() {
        let viewModel = createViewModel(index: 0)
        let viewController = UIViewController()
        viewModel.handleIfUnsaved(viewController)
        let nav = viewModel.nav as! MockNav
        XCTAssertEqual(viewController, nav.popCallArgs[0])
    }

    func testGetAttributedSiteName_hasExpectedName() {
        let viewModel = createViewModel(index: 5)
        XCTAssertEqual("Arms", viewModel.getAttributedSiteName(at: 0)!.string)
        XCTAssertEqual("Left Abdomen", viewModel.getAttributedSiteName(at: 1)!.string)

        let neckIndex = viewModel.siteNameOptions.tryGetIndex(item: "Neck")!
        XCTAssertEqual("Neck", viewModel.getAttributedSiteName(at: neckIndex)!.string)
    }
}
