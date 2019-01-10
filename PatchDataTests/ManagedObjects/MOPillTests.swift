//
//  MOPillTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class MOPillTests: XCTestCase {
    
    // Just use siteSchedule for easy MO generation
    private var pillSchedule: PillSchedule!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        pillSchedule = PillSchedule()
    }
    
    override func tearDown() {
        super.tearDown()
        pillSchedule.reset()
    }
    
    func testLT() {
        let p1 = pillSchedule.insert(completion: nil)
        let p2 = pillSchedule.insert(completion: nil)
        let t2 = Time() as NSDate
        let t1 = Time(timeInterval: -3000, since: t2 as Date) as NSDate
        // p1 : timesaday = 2, timestaken = 0, due should be today at t1
        p1?.setTimesaday(with: 2)
        p1?.setTime1(with: t1)
        p1?.setTime2(with: t2)
        p1?.setTimesTakenToday(with: 0)
        // p2: timesaday = 1, timestaken = 1, due should be tom at t2
        p2?.setTimesaday(with: 1)
        p2?.setTime1(with: t2)
        p2?.setTimesTakenToday(with: 1)
        XCTAssert(p1! < p2!)
    }
    
    func testGT() {
        let p1 = pillSchedule.insert(completion: nil)
        let p2 = pillSchedule.insert(completion: nil)
        let t2 = Time() as NSDate
        let t1 = Time(timeInterval: -3000, since: t2 as Date) as NSDate
        // p1 : timesaday = 2, timestaken = 0, due should be today at t1
        p1?.setTimesaday(with: 2)
        p1?.setTime1(with: t1)
        p1?.setTime2(with: t2)
        p1?.setTimesTakenToday(with: 0)
        // p2: timesaday = 1, timestaken = 1, due should be tom at t2
        p2?.setTimesaday(with: 1)
        p2?.setTime1(with: t2)
        p2?.setTimesTakenToday(with: 1)
        XCTAssert(p2! > p1!)
    }
    
    func testEQ() {
        let p1 = pillSchedule.insert(completion: nil)
        let p2 = pillSchedule.insert(completion: nil)
        let t2 = Time() as NSDate
        let t1 = Time(timeInterval: -3000, since: t2 as Date) as NSDate
        // p1 : timesaday = 2, timestaken = 2, due should be tom at t1
        p1?.setTimesaday(with: 2)
        p1?.setTime1(with: t1)
        p1?.setTime2(with: t2)
        p1?.setTimesTakenToday(with: 2)
        // p2: timesaday = 1, timestaken = 1, due should be tom at t1
        p2?.setTimesaday(with: 1)
        p2?.setTime1(with: t1)
        p2?.setTimesTakenToday(with: 1)
        XCTAssert(p2! == p1!)
    }
    
    func testSetName() {
        let p = pillSchedule.insert(completion: nil)
        p?.setName(with: "NAME")
        XCTAssertEqual(p?.getName(), "NAME")
    }
    
    func testSetTimesaday() {
        let p = pillSchedule.insert(completion: nil)
        p?.setTime1(with: Time() as NSDate)
        p?.setTime2(with: Time() as NSDate)
        p?.setTimesaday(with: -1)
        XCTAssertEqual(p?.getTimesday(), 1)
        p?.setTimesaday(with: 2)
        XCTAssertEqual(p?.getTimesday(), 2)
        // sets time2 to nil when decreases timesaday
        p?.setTime2(with: Time() as NSDate)
        p?.setTimesaday(with: 1)
        XCTAssertNil(p?.getTime2())
    }
    
    func testSetTime1() {
        let p = pillSchedule.insert(completion: nil)
        let t = Time()
        p?.setTime1(with: t as NSDate)
        XCTAssertEqual(p?.getTime1(), t as NSDate)
    }
    
    func testSetTime2() {
        let p = pillSchedule.insert(completion: nil)
        p?.reset()
        let t1 = Time()
        let t2 = Time()
        p?.setTime1(with: t1 as NSDate)
        p?.setTime2(with: t2 as NSDate)
        XCTAssertEqual(p?.getTime2(), t2 as NSDate)
        
        // Sets both t1 and t2 when there is no t1
        let p2 = pillSchedule.insert(completion: nil)
        p2?.reset()
        p2?.setTime2(with: t2 as NSDate)
        XCTAssertEqual(p2?.getTime1(), t2 as NSDate)
        XCTAssertEqual(p2?.getTime2(), t2 as NSDate)
        
        // Swaps t1 and t2 when t2 < t1
        let p3 = pillSchedule.insert(completion: nil)
        p3?.reset()
        let t3 = Time(timeInterval: -3000, since: t1)
        p3?.setTime1(with: t1 as NSDate)
        XCTAssertEqual(p3?.getTime1(), t1 as NSDate)
        p3?.setTime2(with: t3 as NSDate)
        XCTAssertEqual(p3?.getTime1(), t3 as NSDate)
        XCTAssertEqual(p3?.getTime2(), t1 as NSDate)
    }
    
    func testSetNotify() {
        let p = pillSchedule.insert(completion: nil)
        p?.setNotify(with: true)
        XCTAssert((p?.getNotify())!)
    }
    
    func testSetId() {
        let p = pillSchedule.insert(completion: nil)
        let id = p?.setId()
        XCTAssertEqual(id, p?.getId())
    }
    
    func testSetLastTaken() {
        let now = Date()
        let p = pillSchedule.insert(completion: nil)
        p?.setLastTaken(with: now as NSDate)
        XCTAssertEqual(p?.getLastTaken(), now as NSDate)
    }
    
    func testSetTimesTaken() {
        let p = pillSchedule.insert(completion: nil)
        p?.setTimesaday(with: 2)
        p?.setTimesTakenToday(with: 2)
        XCTAssertEqual(p?.getTimesTakenToday(), 2)
        // Doesn't let you take more than timesaday
        p?.setTimesTakenToday(with: 3)
        XCTAssertEqual(p?.getTimesTakenToday(), 2)
    }
    
    func testTake() {
        let p = pillSchedule.insert(completion: nil)
        p?.setTimesaday(with: 1)
        p?.take()
        XCTAssertEqual(p?.getTimesTakenToday(), 1)
        // Doesn't increase when past timesaday
        p?.take()
        XCTAssertEqual(p?.getTimesTakenToday(), 1)
    }
    
    func testDue() {
        let p = pillSchedule.insert(completion: nil)
        p?.reset()
        p?.setTimesaday(with: 1)
        // is nil when pill has no times
        XCTAssertNil(p?.due())

        let t = Time()
        p?.setTime1(with: t as NSDate)
        
        // Should be today at t1 with timesaday = 1 and timesTaken = 1
        var actual = p?.due()
        var expected = PDDateHelper.getDate(at: t, daysFromNow: 0)

        // Should be tomorrow at t1 with timesaday = 1 and timesTaken = 1
        p?.setTimesTakenToday(with: 1)
        actual = p?.due()
        expected = PDDateHelper.getDate(at: t, daysFromNow: 1)
        XCTAssertEqual(actual, expected)

        // Should be today at time 2 when timesaday = 2 and timesTaken = 1
        p?.setTimesaday(with: 2)
        let t2 = Time(timeInterval: 4000, since: t as Date)
        p?.setTime2(with: t2 as NSDate)
        actual = p?.due()
        expected = PDDateHelper.getDate(at: t2 as Time, daysFromNow: 0)
        
        // Should be today at time 1 when timesaday = 2 and timesTaken = 0
        p?.setTimesTakenToday(with: 0)
        actual = p?.due()
        expected = PDDateHelper.getDate(at: t as Time, daysFromNow: 0)
        
        // Should be tomorrow at time 1 when timesaday = 2 and timesTaken = 2
        p?.setTimesTakenToday(with: 2)
        actual = p?.due()
        expected = PDDateHelper.getDate(at: t2 as Time, daysFromNow: 1)
    }
    
    func testIsExpired() {
        let p = pillSchedule.insert(completion: nil)
        let t = PDDateHelper.getDate(at: Time(), daysFromNow: 0)
        p?.setTimesaday(with: 1)
        p?.setTimesTakenToday(with: 0)
        p?.setTime1(with: t! as NSDate)
        // is not expired when never taken before -
        // have to take once to start the schedule
        XCTAssertFalse(p?.isExpired() ?? false)
        // is expired when taken yesterday but not toay
        let d = PDDateHelper.getDate(at: t!, daysFromNow: -1)! as NSDate
        let d2 = Date(timeInterval: -1000, since: d as Date)
        p?.setLastTaken(with: d2 as NSDate)
        XCTAssertEqual(p?.getLastTaken(), d2 as NSDate)
        // is not longer expired after taking
        XCTAssert(Date() > (p?.due())!)
        XCTAssert(p?.isExpired() ?? false)
    }
    
    func testIsNew() {
        let p = pillSchedule.insert(completion: nil)
        XCTAssert(p?.isNew() ?? false)
        p?.setLastTaken(with: NSDate())
        XCTAssertFalse(p?.isNew() ?? false)
    }
    
    func testFixTakenToday() {
        let p = pillSchedule.insert(completion: nil)
        let d = PDDateHelper.getDate(at: Time(), daysFromNow: -1)! as NSDate
        p?.setLastTaken(with: d)
        p?.setTimesTakenToday(with: 1)
        p?.fixTakenToday()
        XCTAssertEqual(p?.getTimesTakenToday(), 0)
    }
    
    func testReset() {
        let p = pillSchedule.insert(completion: nil)
        p?.reset()
        XCTAssertNil(p?.getName())
        XCTAssertEqual(p?.getTimesday(), 1)
        XCTAssertNil(p?.getTime1())
        XCTAssertNil(p?.getTime2())
        XCTAssertFalse(p?.getNotify() ?? false)
        XCTAssertEqual(p?.getTimesTakenToday(), 0)
        XCTAssertNil(p?.getLastTaken())
    }
}
    
