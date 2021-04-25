//
//  PillUndoStateTests.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class PillUndoStateTests: XCTestCase {
    func testPut_whenNoKeyYet_sets() {
        let state = PillUndoState()
        let testDate = Date()
        state.put(at: 1, lastTaken: testDate)

        let actualList = state[1]
        XCTAssertEqual(1, actualList?.count)
        XCTAssertEqual(testDate, actualList![0]!)
    }

    func testPut_canSetMultiple() {
        let state = PillUndoState()
        let testDateOne = Date()
        let testDateTwo = DateFactory.createDate(byAddingHours: 6, to: testDateOne)
        state.put(at: 1, lastTaken: testDateOne)
        state.put(at: 1, lastTaken: testDateTwo)

        let actualList = state[1]
        XCTAssertEqual(2, actualList?.count)
        XCTAssertEqual(testDateOne, actualList![0]!)
        XCTAssertEqual(testDateTwo, actualList![1]!)
    }

    func testPut_handlesMultipleIndices() {
        let state = PillUndoState()
        let testDateOne = Date()
        let testDateTwo = DateFactory.createDate(byAddingHours: 6, to: testDateOne)
        state.put(at: 1, lastTaken: testDateOne)
        state.put(at: 4, lastTaken: testDateTwo)

        let actualFirstList = state[1]
        let actualSecondList = state[4]
        XCTAssertEqual(1, actualFirstList?.count)
        XCTAssertEqual(1, actualSecondList?.count)
        XCTAssertEqual(testDateOne, actualFirstList![0]!)
        XCTAssertEqual(testDateTwo, actualSecondList![0]!)
    }

    func testPopLast_returnsExpectedItem() {
        let state = PillUndoState()
        let testDateOne = Date()
        let testDateTwo = DateFactory.createDate(byAddingHours: 6, to: testDateOne)
        state.put(at: 1, lastTaken: testDateOne)
        state.put(at: 1, lastTaken: testDateTwo)

        XCTAssertEqual(state.popLastTaken(index: 1), testDateTwo)
        XCTAssertEqual(state.popLastTaken(index: 1), testDateOne)
    }
}
