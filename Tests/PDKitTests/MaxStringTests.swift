//
//  MaxStringTests.swift
//  PDKit
//
//  Created by Juliya Smith on 3/15/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class MaxStringTests: XCTestCase {
    public func testCanSet_whenNotExceedingMax_returnsCanReplaceAsTrue() {
        let current = "12"
        let max = 3

        // Adding third and last character.
        let partToAdd = "3"
        let range = NSRange(location: 2, length: 0)

        let actual = TextFieldHelper.canSet(
            currentString: current, replacementString: partToAdd, range: range, max: max
        )
        XCTAssertTrue(actual.canReplace)
    }

    public func testCanSet_whenNotExceedingMax_returnsUpdatedString() {
        let current = "12"
        let max = 3

        // Adding third and last character.
        let partToAdd = "3"
        let range = NSRange(location: 2, length: 0)

        let actual = TextFieldHelper.canSet(
            currentString: current, replacementString: partToAdd, range: range, max: max
        )
        let expected = "123"
        XCTAssertEqual(expected, actual.updatedText)
    }

    public func testCanSet_whenExceedingMax_returnsCanReplaceAsFalse() {
        let current = "123"
        let max = 3

        // Trying to a fourth character but max is 3.
        let partToAdd = "4"
        let range = NSRange(location: max, length: 0)

        let actual = TextFieldHelper.canSet(
            currentString: current, replacementString: partToAdd, range: range, max: max
        )
        XCTAssertFalse(actual.canReplace)
    }

    public func testCanSet_whenExceedingMax_returnsOriginalString() {
        let current = "123"
        let max = 3

        // Trying to a fourth character but max is 3.
        let partToAdd = "4"
        let range = NSRange(location: max, length: 0)

        let actual = TextFieldHelper.canSet(
            currentString: current, replacementString: partToAdd, range: range, max: max
        )
        let expected = current
        XCTAssertEqual(expected, actual.updatedText)
    }
}
