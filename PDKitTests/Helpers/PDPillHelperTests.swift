//
//  PDPillHelperTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/23/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PDKit

class PDPillHelperTests: XCTestCase {
    var times: [Time] = []
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        times = []
    }
    
    func dateIsWithinAMinute(_ lhs: Date, _ rhs: Date) -> Bool {
        return abs(lhs.timeIntervalSince(rhs)) < 60
    }
    
    func testNextDueDateErrors() {
        // Should throw error if timesday > times.count
        do {
            let now = Date()
            let t1 = Date(timeInterval: -3600, since: now)
            times.append(t1)
            let _ = try PDPillHelper.nextDueDate(timesTakenToday: 0, timesaday: 2, times: times)
        } catch {
            XCTAssert(true)
        }
    }
    
    func testNextDueDateOneADay() {
        do {
            let now = Date()
            let t1 = Date(timeInterval: -3600, since: now)
            times.append(t1)
            // With timesaday = 1, times_taken = 0, it should choose time today
            var next = try PDPillHelper.nextDueDate(timesTakenToday: 0, timesaday: 1, times: times)
            if let actual = next {
                XCTAssert(dateIsWithinAMinute(actual, t1))
            } else {
                XCTFail()
            }
            // With timesaday = 1, times_taken = 0, it should choose time today
            next = try PDPillHelper.nextDueDate(timesTakenToday: 1, timesaday: 1, times: times)
            if let actual = next,
                let tmrw = PDDateHelper.getDate(at: t1, daysToAdd: 1) {
                XCTAssert(dateIsWithinAMinute(actual, tmrw))
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func testNextDueDateTwoADay() {
        do {
            let now = Date()
            let t1 = Date(timeInterval: -3600, since: now)
            let t2 = Date(timeInterval: 3600, since: now)
            times.append(t1)
            times.append(t2)
            // With timesaday = 2, times_taken = 0, it should choose smaller time today
            var next = try PDPillHelper.nextDueDate(timesTakenToday: 0, timesaday: 2, times: times)
            if let actual = next {
                let expected = min(t1, t2)
                XCTAssert(dateIsWithinAMinute(actual, expected))
            } else {
                XCTFail()
            }
            // With timesaday = 2, times_taken = 1, it should choose bigger time today
            next = try PDPillHelper.nextDueDate(timesTakenToday: 1, timesaday: 2, times: times)
            if let actual = next {
                let expected = max(t1, t2)
                XCTAssert(dateIsWithinAMinute(actual, expected))
            } else {
                XCTFail()
            }
            // With timesaday = 2, times_taken = 2, it should choose smaller time tomorrow
            next = try PDPillHelper.nextDueDate(timesTakenToday: 2, timesaday: 2, times: times)
            if let actual = next {
                let smaller = min(t1, t2)
                if let tmrw = PDDateHelper.getDate(at: smaller, daysToAdd: 1) {
                    XCTAssert(dateIsWithinAMinute(actual, tmrw))
                }
            } else {
                XCTFail()
            }
            // Handles timesaday being really big
            next = try PDPillHelper.nextDueDate(timesTakenToday: 2000, timesaday: 2, times: times)
            if let actual = next {
                let smaller = min(t1, t2)
                if let tmrw = PDDateHelper.getDate(at: smaller, daysToAdd: 1) {
                    XCTAssert(dateIsWithinAMinute(actual, tmrw))
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
}
