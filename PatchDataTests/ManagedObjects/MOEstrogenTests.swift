//
//  MOEstrogenTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PatchData

class MOEstrogenTests: XCTestCase {
    
    private var estrogenSchedule: EstrogenSchedule!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        estrogenSchedule = EstrogenSchedule()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLT() {
        let e1 = estrogenSchedule.insert()
        let e2 = estrogenSchedule.insert()
        let e3 = estrogenSchedule.insert()
        let d1 = Date();
        let d2 = Date(timeInterval: -1000, since: d1)
        e1?.setDate(with: d1 as NSDate)
        e2?.setDate(with: d2 as NSDate)
        XCTAssertLessThan(e2!, e1!)
        // nil is less than not nil
        XCTAssert(e2! < e1! && e3! < e1! && e3! < e2!)
        // two nils are not less than
        XCTAssertFalse(e3! < e3!)
    }
    
    func testGT() {
        let e1 = estrogenSchedule.insert()
        let e2 = estrogenSchedule.insert()
        let e3 = estrogenSchedule.insert()
        let d1 = Date();
        let d2 = Date(timeInterval: -1000, since: d1)
        e1?.setDate(with: d1 as NSDate)
        e2?.setDate(with: d2 as NSDate)
        XCTAssertGreaterThan(e1!, e2!)
        // nil is less
        XCTAssert(e1! > e2! && e1! > e3! && e2! > e3!)
        // two nils are not greater than
        XCTAssertFalse(e3! > e3!)
    }
    
    func testEQ() {
        let e1 = estrogenSchedule.insert()
        let e2 = estrogenSchedule.insert()
        let e3 = estrogenSchedule.insert()
        let e4 = estrogenSchedule.insert()
        let d = Date();
        e1?.setDate(with: d as NSDate)
        e2?.setDate(with: d as NSDate)
        XCTAssert(e1! == e2!)
        XCTAssert(e3! == e4!)
        XCTAssertFalse(e1! == e4!)
    }
    
    func testNQ() {
        let e1 = estrogenSchedule.insert()
        let e2 = estrogenSchedule.insert()
        let e3 = estrogenSchedule.insert()
        let e4 = estrogenSchedule.insert()
        let d = Date();
        e1?.setDate(with: d as NSDate)
        e2?.setDate(with: d as NSDate)
        XCTAssertFalse(e1! != e2!)
        XCTAssertFalse(e3! != e4!)
        XCTAssert(e1! != e4!)
    }
}
