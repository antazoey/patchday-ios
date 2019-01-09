//
//  MOSiteTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PatchData

class MOSiteTests: XCTestCase {
    
    // Just use these for easy MO generation
    let siteSchedule = SiteSchedule()
    let estrogenScheudle = EstrogenSchedule()
    var defaults: PDDefaults!
    
    override func setUp() {
        super.setUp()
        defaults = PDDefaults(estrogenSchedule: estrogenScheudle,
                              siteSchedule: siteSchedule,
                              state: PDState(),
                              sharedData: nil,
                              alerter: nil)
        defaults.setDeliveryMethod(to: "Patches")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLT() {
        let s1 = siteSchedule.insert()
        let s2 = siteSchedule.insert()
        s1?.setOrder(to: 0)
        s2?.setOrder(to: 1)
        XCTAssert(s1! < s2!)
    }
    
    func testGT() {
        let s1 = siteSchedule.insert()
        let s2 = siteSchedule.insert()
        s1?.setOrder(to: 0)
        s2?.setOrder(to: 1)
        XCTAssert(s2! > s1!)
    }
    
    func testIsOccupied() {
        let estro = estrogenScheudle.getEstrogen(at: 0)!
        let site = siteSchedule.getSite(at: 0)!
        XCTAssertFalse(site.isOccupied())
        estro.setSite(with: site)
        XCTAssert(site.isOccupied())
    }
}
