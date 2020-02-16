//
//  SiteTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


import XCTest
import PDKit
import PDMock

@testable
import PatchData


class SiteTests: XCTestCase {

    func createSite(data: SiteStruct? = nil) -> Site {
        let siteData = data ?? SiteStruct(UUID())
        return Site(siteData: siteData)
    }

    func testHormoneIds_whenNilInData_returnsEmptyList() {
        var data = SiteStruct(UUID())
        data.hormoneRelationshipIds = nil
        let site = createSite(data: data)
        let expected: [UUID] = []
        let actual = site.hormoneIds
        XCTAssertEqual(expected, actual)
    }

    func testImageId_whenNilInData_returnsEmptyString() {
        var data = SiteStruct(UUID())
        data.imageIdentifier = nil
        let site = createSite(data: data)
        let expected = ""
        let actual = site.imageId
        XCTAssertEqual(expected, actual)
    }

    func testSetOrder_whenNewOrderLessThanZero_doesNotSet() {
        var data = SiteStruct(UUID())
        data.order = 3
        let site = createSite(data: data)
        site.order = -9
        let expected = 3
        let actual = site.order
        XCTAssertEqual(expected, actual)
    }

    func testSetOrder_whenNewOrderGreaterThanZero_sets() {
        var data = SiteStruct(UUID())
        data.order = 3
        let site = createSite(data: data)
        site.order = 9
        let expected = 9
        let actual = site.order
        XCTAssertEqual(expected, actual)
    }

    func testName_whenNilInData_returnsEmptyString() {
        var data = SiteStruct(UUID())
        data.name = nil
        let site = createSite(data: data)
        let expected = ""
        let actual = site.name
        XCTAssertEqual(expected, actual)
    }

    func testReset_resetsProperties() {
        var data = SiteStruct(UUID())
        data.name = "Right Booty"
        data.order = 2
        data.imageIdentifier = "Right Booty"
        data.hormoneRelationshipIds = [UUID(), UUID()]
        let site = createSite(data: data)
        site.reset()
        XCTAssert(site.name == "" && site.order == -1 && site.imageId == "" && site.hormoneIds == [])
    }
}
