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
    
    func testSort() {
        if let newEstro = estrogenSchedule?.getEstrogen(at: 0) {
            XCTAssertNil(newEstro.date)
        }
        estrogenSchedule?.delete(after: -1)
        let youngestDate = Date(timeIntervalSince1970: 7000000) as NSDate
        let youngest = estrogenSchedule?.insert()
        youngest?.setDate(with: youngestDate)
        let oldestDate = Date(timeIntervalSince1970: 0) as NSDate
        let oldest = estrogenSchedule?.insert()
        oldest?.setDate(with: oldestDate)
        let middleDate = Date(timeIntervalSince1970: 10000) as NSDate
        let middle = estrogenSchedule?.insert()
        middle?.setDate(with: middleDate)
        estrogenSchedule?.sort()
        if let estro1 = estrogenSchedule?.getEstrogen(at: 0),
            let estro2 = estrogenSchedule?.getEstrogen(at: 1),
            let estro3 = estrogenSchedule?.getEstrogen(at: 2) {
            XCTAssert(estro1 < estro2)
            XCTAssert(estro2 < estro3)
            estro1.setDate(with: youngestDate)
            estrogenSchedule?.sort()
            if let estro4 = estrogenSchedule?.getEstrogen(at: 0) {
                XCTAssertEqual(estro4.date, middleDate)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        estrogenSchedule?.reset()
        XCTAssertEqual(estrogenSchedule?.count(), 3)
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssertEqual(estrogenSchedule?.count(), 1)
    }
    
    func testNew() {
        let estros_start = estrogenSchedule?.estrogens
        estrogenSchedule?.new()
        let _ = estrogenSchedule?.insert()
        // estros_middle has 1 extra
        let estros_middle = estrogenSchedule?.estrogens
        XCTAssertNotEqual(estros_start, estros_middle)

        estrogenSchedule?.new()
        let estros_end = estrogenSchedule?.estrogens
        XCTAssertNotEqual(estros_start?.count, estros_end?.count)
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
