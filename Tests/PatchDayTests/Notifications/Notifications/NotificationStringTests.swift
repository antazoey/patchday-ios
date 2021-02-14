//
//  NotificationStringTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 9/15/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class NotificationStringTests: XCTestCase {

    func testInit_whenPatchesAndExpired_hasCorrectProperties() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Patches
        hormone.siteName = "Hip"
        let actual = NotificationStrings(hormone: hormone)
        let expectedTitle = "Time for your next patch"
        let expectedBody = "Expired Patch from previous site Hip."
        XCTAssertEqual(expectedTitle, actual.title)
        XCTAssertEqual(expectedBody, actual.body)
    }

    func testInit_whenInjectionsAndExpired_hasCorrectProperties() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        hormone.siteName = "Thigh"
        let actual = NotificationStrings(hormone: hormone)
        let expectedTitle = "Time for your next injection"
        let expectedBody = "Expired Injection from previous site Thigh."
        XCTAssertEqual(expectedTitle, actual.title)
        XCTAssertEqual(expectedBody, actual.body)
    }

    func testInit_whenGelAndExpired_hasCorrectProperties() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Gel
        hormone.siteName = "Neck"
        let actual = NotificationStrings(hormone: hormone)
        let expectedTitle = "Time for your gel"
        let expectedBody = "Expired Gel from previous site Neck."
        XCTAssertEqual(expectedTitle, actual.title)
        XCTAssertEqual(expectedBody, actual.body)
    }
}
