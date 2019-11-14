////
////  MOSiteTests.swift
////  PatchDataTests
////
////  Created by Juliya Smith on 1/8/19.
////  Copyright © 2019 Juliya Smith. All rights reserved.
////
//
//import XCTest
//@testable 
//
//class MOSiteTests: XCTestCase {
//    
//    // Just use these for easy MO generation
//    private var siteSchedule: SiteSchedule!
//    private var estrogenSchedule: EstrogenSchedule!
//    private var defaults: UserDefaultsManaging!
//    
//    override func setUp() {
//        super.setUp()
//        PatchData.useTestContainer()
//        siteSchedule = SiteSchedule()
//        estrogenSchedule = EstrogenSchedule()
//        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
//                              siteSchedule: siteSchedule,
//                              state: PDState(),
//                              sharedData: nil,
//                              alerter: nil)
//        defaults.setDeliveryMethod(to: .)
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func testLT() {
//        let site_lower = siteSchedule.insert() as! MOSite
//        let site_higher = siteSchedule.insert() as! MOSite
//        let site_negOrder = siteSchedule.insert() as! MOSite
//        let site_nilOrder = siteSchedule.insert() as! MOSite
//        site_lower.setOrder(0)
//        site_higher.setOrder(1)
//        site_negOrder.setOrder(-23)
//        site_nilOrder.reset()
//        // Sites with lower orders are less than
//        XCTAssert(site_lower < site_higher)
//        // all positive orders are less nil orders
//        XCTAssert(site_lower < site_nilOrder)
//        XCTAssert(site_higher < site_nilOrder)
//        // All positives orders are less than Sites with negative orders
//        // ( I know that sounds backwords, see MOSites desc.)
//        XCTAssert(site_lower < site_negOrder)
//        XCTAssert(site_higher < site_negOrder)
//        // Negative orders are not greater than nil orders and visa versa
//        XCTAssertFalse(site_negOrder < site_nilOrder)
//        XCTAssertFalse(site_nilOrder < site_negOrder)
//    }
//    
//    func testGT() {
//        let site_lower = siteSchedule.insert() as! MOSite
//        let site_higher = siteSchedule.insert() as! MOSite
//        let site_negOrder = siteSchedule.insert() as! MOSite
//        let site_nilOrder = siteSchedule.insert() as! MOSite
//        site_lower.setOrder(0)
//        site_higher.setOrder(1)
//        site_negOrder.setOrder(-23)
//        site_nilOrder.reset()
//        // Sites with higher orders are greater than
//        XCTAssert(site_higher > site_lower)
//        // nil orders are greater than positive orders
//        XCTAssert(site_nilOrder > site_lower)
//        XCTAssert(site_nilOrder > site_higher)
//        // Sites with negative orders are greater than sites with positive orders.
//        // ( I know that sounds backwords, see MOSites desc.)
//        XCTAssert(site_negOrder > site_lower)
//        XCTAssert(site_negOrder > site_higher)
//        // Negative orders are not greater than nil orders and visa versa
//        XCTAssertFalse(site_nilOrder > site_negOrder)
//        XCTAssertFalse(site_negOrder > site_nilOrder)
//    }
//    
//    func testEQ() {
//        let site_lower = siteSchedule.insert() as! MOSite
//        let site_sameAsLower = siteSchedule.insert() as! MOSite
//        let site_higher = siteSchedule.insert() as! MOSite
//        let site_negOrder = siteSchedule.insert() as! MOSite
//        let site_diffNegOrder = siteSchedule.insert() as! MOSite
//        let site_nilOrder = siteSchedule.insert() as! MOSite
//        site_lower.setOrder(0)
//        site_sameAsLower.setOrder(0)
//        site_higher.setOrder(1)
//        site_negOrder.setOrder(-23)
//        site_diffNegOrder.setOrder(-19)
//        site_nilOrder.reset()
//        // Sites with the same order are equal
//        XCTAssert(site_lower == site_sameAsLower)
//        XCTAssert(site_sameAsLower == site_lower)
//        // Sites with different orders are not equal
//        XCTAssertFalse(site_lower == site_higher)
//        XCTAssertFalse(site_higher == site_lower)
//        // Sites with positive orders are not equal to sites with nil orders
//        XCTAssertFalse(site_lower == site_nilOrder)
//        XCTAssertFalse(site_nilOrder == site_higher)
//        // Sites with negative orders are equal regardless of value
//        XCTAssert(site_negOrder == site_diffNegOrder)
//        // Sites with negative orders are equal to sites with nil orders
//        XCTAssert(site_negOrder == site_nilOrder)
//        XCTAssert(site_nilOrder == site_negOrder)
//    }
//    
//    func testNQ() {
//        let site_lower = siteSchedule.insert() as! MOSite
//        let site_sameAsLower = siteSchedule.insert() as! MOSite
//        let site_higher = siteSchedule.insert() as! MOSite
//        let site_negOrder = siteSchedule.insert() as! MOSite
//        let site_diffNegOrder = siteSchedule.insert() as! MOSite
//        let site_nilOrder = siteSchedule.insert() as! MOSite
//        site_lower.setOrder(0)
//        site_sameAsLower.setOrder(0)
//        site_higher.setOrder(1)
//        site_negOrder.setOrder(-23)
//        site_diffNegOrder.setOrder(-19)
//        site_nilOrder.reset()
//        // Sites with the same order are equal
//        XCTAssertFalse(site_lower != site_sameAsLower)
//        XCTAssertFalse(site_sameAsLower != site_lower)
//        // Sites with different orders are not equal
//        XCTAssert(site_lower != site_higher)
//        XCTAssert(site_higher != site_lower)
//        // Sites with positive orders are not equal to sites with nil orders
//        XCTAssert(site_lower != site_nilOrder)
//        XCTAssert(site_nilOrder != site_higher)
//        // Sites with negative orders are equal regardless of value
//        XCTAssertFalse(site_negOrder != site_diffNegOrder)
//        // Sites with negative orders are equal to sites with nil orders
//        XCTAssertFalse(site_negOrder != site_nilOrder)
//        XCTAssertFalse(site_nilOrder != site_negOrder)
//    }
//    
//    func testIsOccupied() {
//        let mone = estrogenSchedule.at(0)!
//        let site = siteSchedule.at(0)!
//        XCTAssertFalse(site.isOccupied())
//        estro.setSite(site)
//        XCTAssert(site.isOccupied())
//        let anotherEstro = estrogenSchedule.at(1)!
//        anotherEstro.setSite(site)
//        XCTAssert(site.isOccupied(byAtLeast: 2))
//        XCTAssertFalse(site.isOccupied(byAtLeast: 3))
//    }
//    
//    func testToString() {
//        let site = siteSchedule.at(0)!
//        site.reset()
//        XCTAssertEqual(site.string(), "0. New Site")
//        site.setOrder(665)
//        site.setName("Devil")
//        XCTAssertEqual(site.string(), "666. Devil")
//    }
//    
//    func testReset() {
//        let site = siteSchedule.at(0)!
//        site.reset()
//        XCTAssertEqual(site.getOrder(), -1)
//        XCTAssertNil(site.getName())
//        XCTAssertNil(site.getImageIdentifer())
//        XCTAssertEqual(site.estrogenRelationship?.count, 0)
//    }
//}
