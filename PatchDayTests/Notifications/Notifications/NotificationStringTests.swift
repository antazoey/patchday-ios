//
//  NotificationStringTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 9/15/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class NotificationStringTests: XCTestCase {
    func testSubscript_whenPatchesAndExpired() {
        let actual = NotificationStrings[.Patches]
        let expected = "Time for your next patch"
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_whenInjectionsAndExpired() {
        let actual = NotificationStrings[.Injections]
        let expected = "Time for your next injection"
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_whenGelAndExpired() {
        let actual = NotificationStrings[.Gel]
        let expected = "Time for your gel"
        XCTAssertEqual(expected, actual)
    }
}
