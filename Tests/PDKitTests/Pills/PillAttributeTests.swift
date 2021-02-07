//
//  PillAttributeTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class PillAttributesTests: XCTestCase {

    func testAnyAttributeExists_whenHasNoProps_returnsFalse() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssertFalse(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasName_returnsTrue() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasExpirationInterval_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: PillExpirationIntervalSetting.EveryDay,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasTimes_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: "12:30",
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasNotify_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: false,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasTimesTakenToday_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 0,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasLastTaken_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: Date(),
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasXDays_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: "1"
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testReset_resetsAllPropertiesToNil() {
        let attributes = PillAttributes(
            name: "name",
            expirationIntervalSetting: .EveryDay,
            times: "1200",
            notify: true,
            timesTakenToday: 4,
            lastTaken: Date(),
            xDays: "7"
        )
        attributes.reset()
        XCTAssertNil(attributes.name)
        XCTAssertNil(attributes.expirationIntervalSetting)
        XCTAssertNil(attributes.times)
        XCTAssertNil(attributes.notify)
        XCTAssertNil(attributes.timesTakenToday)
        XCTAssertNil(attributes.lastTaken)
        XCTAssertNil(attributes.xDays)
    }
}
