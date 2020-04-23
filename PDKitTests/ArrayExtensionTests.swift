//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class ArrayExtensionTests: XCTestCase {

	func testTryGet_whenIndexOutOfRange_returnsNil() {
		let intList = [1, 2, 3]
		XCTAssertNil(intList.tryGet(at: 3))
	}

	func testTryGet_whenIndexInRange_returnsExpectedValue() {
		let intList = [1, 2, 3]
		let expected = 2
		let actual = intList.tryGet(at: 1)
		XCTAssertEqual(expected, actual)
	}

	func testTryGetIndex_whenItemDoesNotExist_returnsNil() {
		let intList = [1, 2, 3]
		XCTAssertNil(intList.tryGetIndex(item: 4))
	}

	func testTryGetIndex_whenItemExists_returnsExpectedValue() {
		let intList = [1, 2, 3]
		let expected = 1
		let actual = intList.tryGetIndex(item: 2)
		XCTAssertEqual(expected, actual)
	}
}
