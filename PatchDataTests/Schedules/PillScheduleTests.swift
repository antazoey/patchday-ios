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

    private var pillSchedule: PillSchedule!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        pillSchedule = PillSchedule()
        pillSchedule.reset()
        let t1 = Time()
        let t2 = Time(timeInterval: 3000, since: t1)
        let last = Time(timeInterval: -15000, since: t1)
        let a = PillAttributes(name: "PILL 1",
                                timesaday: 2,
                                time1: t1,
                                time2: t2,
                                notify: false,
                                timesTakenToday: 0,
                                lastTaken: last)
        pillSchedule.setPill(at: 0, with: a)
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
        let e1 = expectation(description: "SetSharedData called")
        
        pillSchedule.takePill(at: 0) {
            e1.fulfill()
        }
        wait(for: [e1], timeout: 3)
        // Taking once increased to 1
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
        } else {
            XCTFail()
        }
        // Taking twice increase to 2
        pillSchedule.takePill(at: 0, setPDSharedData: nil)
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
        } else {
            XCTFail()
        }

        var called = false
        pillSchedule.takePill(at: 0) {
            called = true
        }
        // Won't take or callback
        XCTAssertFalse(called)
        // But can't take more than the pill's timesday
        if let pill = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
        } else {
            XCTFail()
        }
    }
    
    func testTakePill() {
        if let pill = pillSchedule.getPill(at: 0) {
            let e1 = expectation(description: "Shared data set.")
            pillSchedule.take(pill) {
                e1.fulfill()
            }
            wait(for: [e1], timeout: 3)
            XCTAssertEqual(pill.getTimesTakenToday(), 1)
            pillSchedule.take(pill, setPDSharedData: nil)
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
            // Does not permit taking more than "timesaday"
            var set = false
            pillSchedule.take(pill) {
                set = true
            }
            XCTAssertFalse(set)
            XCTAssertEqual(pill.getTimesTakenToday(), 2)
        }
    }
    
    func testNextDue() {
        let t = Time(timeInterval: 500,
                     since: pillSchedule.getPill(at: 0)!.getTime1()! as Date)
        let last = Time(timeInterval: -15000, since: t)
        let a = PillAttributes(name: "PILL 2",
                                timesaday: 1,
                                time1: t,
                                time2: nil,
                                notify: false,
                                timesTakenToday: 0,
                                lastTaken: last)
        pillSchedule.setPill(at: 1, with: a)
        var nextDue = pillSchedule.nextDue()
        XCTAssertEqual(pillSchedule.getPill(at: 0)!, nextDue)
        // After taking, the other pill should be the next.
        pillSchedule.take(setPDSharedData: nil)
        nextDue = pillSchedule.nextDue()
        XCTAssertEqual(pillSchedule.getPill(at: 1)!, nextDue)
        // Take again and then first one should be the next
        pillSchedule.take(setPDSharedData: nil)
        nextDue = pillSchedule.nextDue()
        XCTAssertEqual(pillSchedule.getPill(at: 0)!, nextDue)
    }
    
    func testTotalDue() {
        pillSchedule.reset()
        XCTAssertEqual(pillSchedule.totalDue(), 0)
        let now = Date()
        let earlier = Date(timeInterval: -1000, since: now)
        let yesterday = Date(timeInterval: -86400, since: earlier)
        pillSchedule.getPill(at: 0)?.setLastTaken(with: yesterday as NSDate)
        pillSchedule.getPill(at: 0)?.setTime1(with: earlier as NSDate)
        XCTAssertEqual(pillSchedule.totalDue(), 1)
        let pill = pillSchedule.insert(completion: nil)
        pill?.setLastTaken(with: yesterday as NSDate)
        pill?.setTime1(with: earlier as NSDate)
        XCTAssertEqual(pillSchedule.totalDue(), 2)
        pillSchedule.take()
        XCTAssertEqual(pillSchedule.totalDue(), 1)
        let next = pillSchedule.nextDue()!
        pillSchedule.take()
        XCTAssertEqual(pillSchedule.totalDue(), 0)
        // should account for a newly added due pill
        next.setTimesaday(with: 2)
        next.setTime2(with: Date(timeInterval: -1000, since: Date()) as NSDate)
        XCTAssertEqual(pillSchedule.totalDue(), 1)
    }
}
