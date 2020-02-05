//
//  PillTests.swift
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


public class PillTests: XCTestCase {
    
    let testId = UUID()

    public func createPill(_ attributes: PillAttributes) -> Pill {
        return Pill(pillData: PillStruct(UUID(), attributes))
    }
    
    public func testTimeOne_whenNilInAttributes_returnsDefaultDate() {
        var attrs = PillAttributes()
        attrs.time1 = nil
        let pill = createPill(attrs)
        let expected = Date(timeIntervalSince1970: 0)
        let actual = pill.time1
        XCTAssertEqual(expected, actual)
    }
    
    public func testTimeOne_returnsTimeFromAttributes() {
        var attrs = PillAttributes()
        attrs.time1 = Date()
        let pill = createPill(attrs)
        let expected = attrs.time1
        let actual = pill.time1
        XCTAssertEqual(expected, actual)
    }
    
    public func testTimeTwo_whenNilInAttributes_returnsDefaultDate() {
        var attrs = PillAttributes()
        attrs.time2 = nil
        let pill = createPill(attrs)
        let expected = Date(timeIntervalSince1970: 0)
        let actual = pill.time2
        XCTAssertEqual(expected, actual)
    }
    
    public func testTimeTwo_returnsTimeFromAttributes() {
        var attrs = PillAttributes()
        attrs.time2 = Date()
        let pill = createPill(attrs)
        let expected = attrs.time2
        let actual = pill.time2
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetTimeTwo_whenTimeOneIsGreater_setsPillOneToNewTime() {
        var attrs = PillAttributes()
        attrs.time1 = Date(timeInterval: 1000, since: Date())
        let pill = createPill(attrs)
        let expected = Date()
        pill.time2 = expected
        XCTAssertEqual(expected, pill.time1)
    }
    
    public func testSetTimeTwo_whenTimeOneIsGreater_setsTimeTwoToPillTimeOne() {
        var attrs = PillAttributes()
        let expected = Date(timeInterval: 1000, since: Date())
        attrs.time1 = expected
        let pill = createPill(attrs)
        pill.time2 = Date()
        XCTAssertEqual(expected, pill.time2)
    }
    
    public func testNotify_whenNilInAttributes_returnsFalse() {
        var attrs = PillAttributes()
        attrs.notify = nil
        let pill = createPill(attrs)
        XCTAssertFalse(pill.notify)
    }
    
    public func testTimesaday_whenNilInAttributes_returnsDefaultTimesaday() {
        var attrs = PillAttributes()
        attrs.notify = nil
        let pill = createPill(attrs)
        let expected = DefaultPillAttributes.timesaday
        let actual = pill.timesaday
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetTimesaday_whenNewValueLessThanZero_doesNotSet() {
        var attrs = PillAttributes()
        attrs.timesaday = 3
        let pill = createPill(attrs)
        pill.timesaday = -4
        let expected = 3
        let actual = pill.timesaday
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetTimesaday_whenNewValuePositive_sets() {
        let pill = createPill(PillAttributes())
        pill.timesaday = 16
        let expected = 16
        let actual = pill.timesaday
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetTimesaday_whenNewValueEqualToOne_clearsTimeTwo() {
        var attrs = PillAttributes()
        attrs.time2 = Date()
        let pill = createPill(attrs)
        pill.timesaday = 1
        let expected = Date(timeIntervalSince1970: 0)
        let actual = pill.time2
        XCTAssertEqual(expected, actual)
    }
    
    public func testTimesTakenToday_whenNilInAttributes_returnsZero() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = nil
        let pill = createPill(attrs)
        let expected = 0
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }
    
    public func testTimesTakenToday_whenNotNilInAttributes_returnsValueFromAttributes() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = 19
        let pill = createPill(attrs)
        let expected = 19
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }
}
