//
//  EstrogenScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class EstrogenScheduleTests: XCTestCase {
    
    var estrogenSchedule: EstrogenSchedule? = nil

    override func setUp() {
        super.setUp()
        estrogenSchedule = EstrogenSchedule()
        if let schedule = estrogenSchedule {
            PDDefaults.setEstrogenSchedule(schedule)
        }
        PDDefaults.setDeliveryMethod(to: "Patches")
    }
    
    override func tearDown() {
        super.tearDown()
        estrogenSchedule?.delete(after: -1)
    }
    
    func testCount() {
        XCTAssertEqual(estrogenSchedule?.count(), 3)
        let _ = estrogenSchedule?.insert()
        XCTAssertEqual(estrogenSchedule?.count(), 4)
    }
    
    func testInsert() {
        estrogenSchedule?.delete(after: -1)
        for _ in 0..<50 {
            let _ = estrogenSchedule?.insert()
        }
        XCTAssertEqual(estrogenSchedule?.count(), 50)
    }
    
    func testReset() {
        estrogenSchedule?.reset()
        XCTAssertEqual(estrogenSchedule?.count(), 3)
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssertEqual(estrogenSchedule?.count(), 1)
    }
    
    func testDeleteAfterIndex() {
        let _ = estrogenSchedule?.insert()
        XCTAssertEqual(estrogenSchedule?.count(), 4)
        estrogenSchedule?.delete(after: 1)
        XCTAssertEqual(estrogenSchedule?.count(), 2)
        // No change when index too high
        estrogenSchedule?.delete(after: 1)
        XCTAssertEqual(estrogenSchedule?.count(), 2)
        // Negative numbers will erase it all
        estrogenSchedule?.delete(after: -2000)
        XCTAssertEqual(estrogenSchedule?.count(), 0)
        let _ = estrogenSchedule?.insert()
        XCTAssertEqual(estrogenSchedule?.count(), 1)
        estrogenSchedule?.delete(after: 0)
        XCTAssertEqual(estrogenSchedule?.count(), 1)
        estrogenSchedule?.delete(after: -1)
        XCTAssertEqual(estrogenSchedule?.count(), 0)
    }
    
}
