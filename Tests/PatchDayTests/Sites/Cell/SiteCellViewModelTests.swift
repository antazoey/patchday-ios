//
//  SiteCellViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 10/15/20.

import Foundation

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SiteCellViewModelTests: PDTestCase {
    func testSiteNameText_whenSiteIsNull_returnsNewSite() {
        var props = SiteCellProperties(row: 0)
        props.site = nil
        let viewModel = SiteCellViewModel(props)
        let expected = SiteStrings.NewSite
        let actual = viewModel.siteNameText
        XCTAssertEqual(expected, actual)
    }

    func testSiteNameText_whenSiteNameIsEmptyString_returnsNewSite() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.name = ""
        props.site = site
        let viewModel = SiteCellViewModel(props)
        let expected = SiteStrings.NewSite
        let actual = viewModel.siteNameText
        XCTAssertEqual(expected, actual)
    }

    func testSiteNameText_whenSiteNameIsValid_returnsSiteName() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.name = "Site Name"
        props.site = site
        let viewModel = SiteCellViewModel(props)
        let expected = site.name
        let actual = viewModel.siteNameText
        XCTAssertEqual(expected, actual)
    }

    func testOrderText_whenSiteIsNil_returnsEmptyString() {
        var props = SiteCellProperties(row: 0)
        props.site = nil
        let viewModel = SiteCellViewModel(props)
        let expected = ""
        let actual = viewModel.orderText
        XCTAssertEqual(expected, actual)
    }

    func testOrderText_returnsOrderPlusOneAsString() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.site = site
        let viewModel = SiteCellViewModel(props)
        let expected = "3."
        let actual = viewModel.orderText
        XCTAssertEqual(expected, actual)
    }

    func testGetVisibilityBools_whenEditingAndSiteOrderIsNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 2
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: true)

        // It is because we are in editing mode that we hide the next label
        XCTAssertTrue(actual.hideNext)
        XCTAssertTrue(actual.hideOrder)
    }

    func testGetVisibilityBools_whenIsNotEditingAndSiteOrderIsNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.site = site
        props.nextSiteIndex = 2
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertFalse(actual.hideNext)
        XCTAssertFalse(actual.hideOrder)
    }

    func testGetVisibilityBools_whenEditingAndSiteOrderIsNotNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 3
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: true)
        XCTAssertTrue(actual.hideNext)
        XCTAssertTrue(actual.hideOrder)
    }

    func testGetVisibilityBools_whenIsNotEditingAndSiteOrderIsNotNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 3
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertTrue(actual.hideNext)
        XCTAssertFalse(actual.hideOrder)
    }

    func testGetVisibilityBools_whenIsEditing_returnsExpectedHideArrowValue() {
        let props = SiteCellProperties(row: 0)
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: true)
        XCTAssertTrue(actual.hideArrow)
    }

    func testGetVisibilityBools_whenSiteOrderIsNextAndNotEditing_saysDoNotHideArrow() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 3
        props.nextSiteIndex = 3
        props.site = site
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertTrue(actual.hideArrow)
    }

    func testGetVisibilityBools_whenSiteOrderIsNotNextAndNotEditing_doesNotToHideArrow() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 3
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertFalse(actual.hideArrow)
    }
}
