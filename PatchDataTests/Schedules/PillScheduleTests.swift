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
        let t2 = Time()
        let t1 = Time(timeInterval: -3000, since: t2)
        let lastTaken = Time(timeInterval: -15000, since: t1)
        let a1 = PillAttributes(name: "PILL 1",
                                timesaday: 2,
                                time1: t1,
                                time2: t2,
                                notify: false,
                                timesTakenToday: 0,
                                lastTaken: lastTaken,
                                id: UUID())
        pillSchedule.setPill(at: 0, with: a1)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetPill() {
        let expected = "PILL 1"
        if let p1 = pillSchedule.getPill(at: 0) {
            XCTAssertEqual(p1.getName(), expected)
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
}
