//
//  SiteCellViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 10/15/20.

import Foundation

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SiteCellViewModelTests: XCTestCase {
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
        XCTAssertFalse(actual.showNext)
        XCTAssertFalse(actual.showOrder)
    }

    func testGetVisibilityBools_whenIsNotEditingAndSiteOrderIsNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 2
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertFalse(actual.showNext)
        XCTAssert(actual.showOrder)
    }

    func testGetVisibilityBools_whenEditingAndSiteOrderIsNotNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 3
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: true)
        XCTAssertFalse(actual.showNext)
        XCTAssertFalse(actual.showOrder)
    }

    func testGetVisibilityBools_whenIsNotEditingAndSiteOrderIsNotNext_returnsExpectedBools() {
        var props = SiteCellProperties(row: 0)
        let site = MockSite()
        site.order = 2
        props.nextSiteIndex = 3
        let viewModel = SiteCellViewModel(props)
        let actual = viewModel.getVisibilityBools(cellIsInEditMode: false)
        XCTAssertFalse(actual.showNext)
        XCTAssert(actual.showOrder)
    }
}
