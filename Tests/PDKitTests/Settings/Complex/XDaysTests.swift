//
//  XDaysTests.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class XDaysTests: XCTestCase {

    func testUd_returnsUserDefaultObjectWithRawValue() {
        let obj = XDays()
        obj.rawValue = "2"
        let actual = obj.ud.value
        XCTAssertEqual("2", actual)
    }

    func testValue_whenRawValueCanBeInt_returnsInt() {
        let obj = XDays()
        obj.rawValue = "45"
        let actual = obj.value
        let expected = 45
        XCTAssertEqual(expected, actual)
    }

    func testValue_whenRawValueCannotBeInt_returnsNil() {
        let obj = XDays()
        obj.rawValue = "45z"
        XCTAssertNil(obj.value)
    }

    func testSetValue_setsRawValueToStringifiedInt() {
        let obj = XDays()
        obj.value = 3
        let actual = obj.rawValue
        let expected = "3"
        XCTAssertEqual(expected, actual)
    }

    func testSetValue_canSetToNil() {
        let obj = XDays()
        obj.value = nil
        XCTAssertNil(obj.value)
    }
}
