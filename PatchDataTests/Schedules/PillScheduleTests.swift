//
//  PillScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 12/27/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class PillScheduleTests: XCTestCase {
    let pillSchedule = PillSchedule()
    
    override func setUp() {
        super.setUp()
        pillSchedule.reset()
        let t2 = Time()
        let t1 = Time(timeInterval: -3000, since: t2)
        let lastTaken = Time(timeInterval: -15000, since: t1)
        let a1 = PillAttributes(name: "PILL 1",
                                timesaday: 2,
                                time1: t1,
                                time2: t2,
                                notify: false,
                                timesTakenToday: 0,
                                lastTaken: lastTaken)
        pillSchedule.setPill(at: 0, with: a1)
    }
    
    override func tearDown() {
        super.tearDown()
        pillSchedule.reset()
    }
    
    func testCount() {
        XCTAssertEqual(pillSchedule.count(), 2)
    }
    
    func testInsert() {
        if let pill = pillSchedule.insert(completion: nil) {
            XCTAssert(pillSchedule.pills.contains(pill))
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        pillSchedule.reset()
        XCTAssertEqual(pillSchedule.count(), 2)
    }
    
    func testDelete() {
        pillSchedule.delete(at: 0)
        XCTAssertEqual(pillSchedule.count(), 1)
        // Doesn't delete when out of range
        pillSchedule.delete(at: -1)
        XCTAssertEqual(pillSchedule.count(), 1)
        // Doesn't delete when out of range
        pillSchedule.delete(at: 10)
        XCTAssertEqual(pillSchedule.count(), 1)
    }
    
    func testNew() {
        pillSchedule.new()
        XCTAssertEqual(pillSchedule.count(), 2)
    }

    func testGetPillAtIndex() {
        let expected = "PILL 1"
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getName(), expected)
        } else {
            XCTFail()
        }
        if let _ = pillSchedule.getPill(at: -1) {
            XCTFail()
        }
        if let _ = pillSchedule.getPill(at: 1000) {
            XCTFail()
        }
    }
    
    func testGetPillForId() {
        if let pill = pillSchedule.getPill(at: 0),
            let id = pill.getId() {
            let actual = pillSchedule.getPill(for: id)
            let expected = pill
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        let id = UUID()
        XCTAssertNil(pillSchedule.getPill(for: id))
    }
    
    func testSetPillAtIndex() {
        let t = Time()
        let d = Date(timeInterval: -10, since: t)
        let attributes = PillAttributes(name: "NEW PILL",
                                        timesaday: 2,
                                        time1: t,
                                        time2: t,
                                        notify: false,
                                        timesTakenToday: 1,
                                        lastTaken: d)
        pillSchedule.setPill(at: 1, with: attributes)
        if let pill = pillSchedule.getPill(at: 1) {
            XCTAssertNotNil(pill.getId())
            XCTAssertEqual(pill.getName(), "NEW PILL")
            XCTAssertEqual(pill.getTimesday(), 2)
            XCTAssertEqual(pill.getTime1(), t as NSDate)
            XCTAssertEqual(pill.getTime2(), t as NSDate)
            XCTAssertEqual(pill.getNotify(), false)
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
            XCTAssertEqual(pill.getLastTaken(), d as NSDate)
        } else {
            XCTFail()
        }
    }
    
    func testSetPillForPill() {
        if let pill = pillSchedule.getPill(at: 0) {
            let t = Time()
            let d = Date(timeInterval: -10, since: t)
            let attributes = PillAttributes(name: "NEW PILL",
                                            timesaday: 2,
                                            time1: t,
                                            time2: t,
                                            notify: false,
                                            timesTakenToday: 1,
                                            lastTaken: d)
            pillSchedule.setPill(at: 1, with: attributes)
            pillSchedule.setPill(for: pill, with: attributes)
            XCTAssertNotNil(pill.getId())
            XCTAssertEqual(pill.getName(), "NEW PILL")
            XCTAssertEqual(pill.getTimesday(), 2)
            XCTAssertEqual(pill.getTime1(), t as NSDate)
            XCTAssertEqual(pill.getTime2(), t as NSDate)
            XCTAssertEqual(pill.getNotify(), false)
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
            XCTAssertEqual(pill.getLastTaken(), d as NSDate)
        } else {
            XCTFail()
        }
    }
    
    func testTakeAt() {
        var mockCalled = false
        let mock: () -> () = {
            mockCalled = true
        }
        pillSchedule.takePill(at: 0, setPDSharedData: mock)
        XCTAssert(mockCalled)
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
        }
        pillSchedule.takePill(at: 0, setPDSharedData: nil)
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
        }
        mockCalled = false
        pillSchedule.takePill(at: 0, setPDSharedData: mock)
        XCTAssertFalse(mockCalled)
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
        }
    }
    
    func testTakePill() {
        var mockCalled = false
        let mock: () -> () = {
            mockCalled = true
        }
        if let pill = pillSchedule.getPill(at: 0) {
            pillSchedule.take(pill, setPDSharedData: mock)
            XCTAssert(mockCalled)
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
            pillSchedule.take(pill, setPDSharedData: nil)
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
            // Does not permit taking more than "timesaday"
            mockCalled = false
            pillSchedule.take(pill, setPDSharedData: mock)
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
            XCTAssertFalse(mockCalled)
        }
    }
    
    func testNextDue() {
        
    }
}
