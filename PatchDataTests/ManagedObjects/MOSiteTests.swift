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
    private var siteSchedule: SiteSchedule!
    private var estrogenSchedule: EstrogenSchedule!
    private var defaults: PDDefaults!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        siteSchedule = SiteSchedule()
        estrogenSchedule = EstrogenSchedule()
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
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
        let estro = estrogenSchedule.getEstrogen(at: 0)!
        let site = siteSchedule.getSite(at: 0)!
        XCTAssertFalse(site.isOccupied())
        estro.setSite(with: site)
        XCTAssert(site.isOccupied())
        let anotherEstro = estrogenSchedule.getEstrogen(at: 1)!
        anotherEstro.setSite(with: site)
        XCTAssert(site.isOccupied(byAtLeast: 2))
        XCTAssertFalse(site.isOccupied(byAtLeast: 3))
    }
    
    func testToString() {
        let site = siteSchedule.getSite(at: 0)!
        site.reset()
        XCTAssertEqual(site.string(), "0. New Site")
        site.setOrder(to: 665)
        site.setName(to: "Devil")
        XCTAssertEqual(site.string(), "666. Devil")
    }
    
    func testDecrement() {
        let site = siteSchedule.getSite(at: 0)!
        XCTAssertEqual(site.getOrder(), 0)
        // Does not decrement when already 0
        site.decrement()
        XCTAssertEqual(site.getOrder(), 0)
        site.setOrder(to: 666)
        site.decrement()
        XCTAssertEqual(site.getOrder(), 666 - 1)
    }
    
    func testReset() {
        let site = siteSchedule.getSite(at: 0)!
        site.reset()
        XCTAssertEqual(site.getOrder(), -1)
        XCTAssertNil(site.getName())
        XCTAssertNil(site.getImageIdentifer())
        XCTAssertEqual(site.estrogenRelationship?.count, 0)
    }
}
