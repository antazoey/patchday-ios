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
    let pillSchedule = PillSchedule()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLT() {
        let p1 = pillSchedule.insert(completion: nil)
        let p2 = pillSchedule.insert(completion: nil)
        let t2 = Time() as NSDate
        let t1 = Time(timeInterval: -3000, since: t2 as Date) as NSDate
        p1?.setTimesaday(with: 2)
        p1?.setTime1(with: t1)
        p1?.setTime2(with: t2)
        p2?.setTimesaday(with: 1)
        p2?.setTime1(with: t2)
        p1?.take()
        XCTAssert(p2! < p1!)
    }
    
    func testGT() {
    }
    
    func testGetDueDate() {
        let p = pillSchedule.insert(completion: nil)
        let t = Time() as NSDate
        p?.setTime1(with: t)
        p?.take()
        let expected = PDDateHelper.getD
    }
}
    
