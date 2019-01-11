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
        let estro_recent = estrogenSchedule.insert()!
        let estro_next = estrogenSchedule.insert()!
        let estro_nilDate = estrogenSchedule.insert()!
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(with: later as NSDate)
        estro_next.setDate(with: earlier as NSDate)
        // The etrogens that need to be changed next are <
        XCTAssert(estro_next < estro_recent)
        // not nil is < nil
        XCTAssert(estro_recent < estro_nilDate && estro_next < estro_nilDate)
        // two nils are not less than
        XCTAssertFalse(estro_nilDate < estro_nilDate)
    }
    
    func testGT() {
        let estro_recent = estrogenSchedule.insert()!
        let estro_next = estrogenSchedule.insert()!
        let estro_nilDate = estrogenSchedule.insert()!
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(with: later as NSDate)
        estro_next.setDate(with: earlier as NSDate)
        // The etrogens that were changed recently are >
        XCTAssert(estro_recent > estro_next)
        // nil is > not nil
        XCTAssert(estro_nilDate > estro_recent)
        XCTAssert(estro_nilDate > estro_next)
        // two nils are not greater than
        XCTAssertFalse(estro_nilDate > estro_nilDate)
    }
    
    func testEQ() {
        let estro_recent = estrogenSchedule.insert()!
        let estro_sameDateAsRecent = estrogenSchedule.insert()!
        let estro_next = estrogenSchedule.insert()!
        let estro_nilDate = estrogenSchedule.insert()!
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(with: later as NSDate)
        estro_sameDateAsRecent.setDate(with: later as NSDate)
        estro_next.setDate(with: earlier as NSDate)
        // Estrogens with the same date are equal
        XCTAssert(estro_recent == estro_sameDateAsRecent)
        // Estrogens with different dates not equal
        XCTAssertFalse(estro_recent == estro_next)
        // nil is not equal to not nil
        XCTAssertFalse (estro_recent == estro_nilDate)
        XCTAssertFalse(estro_nilDate == estro_recent)
        // two nils are not greater than
        XCTAssertFalse(estro_nilDate > estro_nilDate)
    }
    
    func testNQ() {
        let estro_recent = estrogenSchedule.insert()!
        let estro_sameDateAsRecent = estrogenSchedule.insert()!
        let estro_next = estrogenSchedule.insert()!
        let estro_nilDate = estrogenSchedule.insert()!
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(with: later as NSDate)
        estro_sameDateAsRecent.setDate(with: later as NSDate)
        estro_next.setDate(with: earlier as NSDate)
        // Estrogens with different dates are not equal
        XCTAssert(estro_recent != estro_next)
        // Estrogens with the same date are equal
        XCTAssertFalse(estro_recent != estro_sameDateAsRecent)
        // nil is not equal to not nil
        XCTAssert (estro_recent != estro_nilDate)
        XCTAssert(estro_nilDate != estro_recent)
        // two nils are not greater than
        XCTAssertFalse(estro_nilDate > estro_nilDate)
    }
}
