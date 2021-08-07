//
//  TestPillAttributesFactory.swift
//  PDTest
//
//  Created by Juliya Smith on 8/4/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import XCTest

public class PillTestFixtures {
    public static func createAttributesForXDaysOnXDaysOff(
        daysOne: Int?=nil, daysTwo: Int?=nil, isOn: Bool?=nil, daysPosition: Int?=nil
    ) -> PillAttributes {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .XDaysOnXDaysOff
        attributes.expirationInterval.daysOne = daysOne
        attributes.expirationInterval.daysTwo = daysTwo
        attributes.expirationInterval.xDaysIsOn = isOn
        attributes.expirationInterval.xDaysPosition = daysPosition
        return attributes
    }

    public static func assertPosition(
        _ expectedPosition: Int,
        _ expectedBool: Bool,
        _ interval: PillExpirationInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let isOn = interval.xDaysIsOn else {
            XCTFail("XDays position is not turned on.", file: file, line: line)
            return
        }
        guard let position = interval.xDaysPosition else {
            XCTFail("XDays position is not initialized.", file: file, line: line)
            return
        }
        XCTAssertEqual(expectedBool, isOn, file: file, line: line)
        XCTAssertEqual(expectedPosition,position, file: file, line: line)
    }

    public static func assertNilPosition(
        _ interval: PillExpirationInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNil(interval.xDaysIsOn, file: file, line: line)
        XCTAssertNil(interval.xDaysPosition, file: file, line: line)
    }
}
