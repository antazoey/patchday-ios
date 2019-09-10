//
//  DateExtensionTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 1/4/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable import PDKit

class DateExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIsWithinMinutes() {
        let d1 = Date()
        let d2 = Date()
        let d3 = Date.createDefaultDate()
        XCTAssert(d1.isWithin(minutes: 1, of: d2))
        XCTAssert(!d1.isWithin(minutes: 100, of: d3))
    }
    
    func testIsInPast() {
        let now = Date()
        let past = Date(timeInterval: -5000, since: now)
        let future = Date(timeInterval: 5000, since: now)
        XCTAssert(past.isInPast())
        XCTAssert(!future.isInPast())
    }
    
    func testIsInToday() {
        let date = Date.createDefaultDate()
        XCTAssertTrue(Date().isInToday())
        XCTAssertFalse(date.isInToday())
    }
    
    func testIsOvernight() {
        if let threeAM = Calendar.current.date(bySettingHour: 3,
                                               minute: 0,
                                               second: 0,
                                               of: Date()) {
            XCTAssert(threeAM.isOvernight())
        } else {
            XCTFail()
        }
        if let threePM = Calendar.current.date(bySettingHour: 15,
                                               minute: 0,
                                               second: 0,
                                               of: Date()) {
            XCTAssert(!threePM.isOvernight())
        } else {
            XCTFail()
        }
    }
}
