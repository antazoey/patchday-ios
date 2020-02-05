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
    
    // Note: If you run these tests at like midnight, you might get weird results.
    // For example, the tests may assume it can add seconds to the current time and have it still be today.
    
    func testIsWithinMinutes_returnsTrueWhenGivenDateIsWithinGivenMinutes() {
        let d1 = Date()
        let d2 = Date()
        XCTAssertTrue(d1.isWithin(minutes: 1, of: d2))
    }
    
    func testIsWithinMinutes_returnsFalseWhenDateIsWithinGivenMinutes() {
        let d1 = Date()
        let d3 = Date.createDefaultDate()
        XCTAssertFalse(d1.isWithin(minutes: 100, of: d3))
    }
    
    func testIsWithinMinutes_whenDatesAreSameAndGivenZeroMinutes_returnsTrue() {
        let d1 = Date()
        XCTAssertTrue(d1.isWithin(minutes: 0, of: d1))
    }

    func testIsInPast_whenGivenDateThatIsInPast_returnsTrue() {
        let past = Date(timeInterval: -5000, since: Date())
        XCTAssertTrue(past.isInPast())
    }

    func testIsInPast_whenGivenDateThatIsInInFuture_returnsFalse() {
        let future = Date(timeInterval: 5000, since: Date())
        XCTAssertFalse(future.isInPast())
    }
    
    func testIsInToday_whenGivenDateThatIsNow_returnsTrue() {
        XCTAssertTrue(Date().isInToday())
    }
    
    func testIsInToday_whenGivenDateThatIsInPastMoreThanADay_returnsFalse() {
        XCTAssertFalse(Date.createDefaultDate().isInToday())
    }
    
    func testIsInToday_whenGivenDateThatIsInFutureMoreThanADay_returnsFalse() {
        let future = Date(timeInterval: 500000, since: Date())
        XCTAssertFalse(future.isInToday())
    }
    
    func testIsOvernight_whenGivenThreeAM_returnsTrue() {
        let threeAM = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: Date())!
        XCTAssertTrue(threeAM.isOvernight())
    }
    
    func testIsOvernight_whenGivenThreePM_returnsFalse() {
        let threePM = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
        XCTAssertFalse(threePM.isOvernight())
    }
}
