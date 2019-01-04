//
//  PDDefaultsTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 12/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class PDDefaultsTests: XCTestCase {

    private let estrogenSchedule = EstrogenSchedule()
    private let siteSchedule = SiteSchedule()
    private let scheduleState = ScheduleState()
    public var defaults: PDDefaults! = nil
    
    override func setUp() {
        super.setUp()
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              scheduleState: scheduleState,
                              alerter: nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// Test that the estrogen schedule reflects changes from defaults
    func testEstrogenSchedule() {
        defaults.setQuantityWithoutWarning(to: 4)
        let date = Date(timeIntervalSince1970: 0)
        estrogenSchedule.setDate(of: 0, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 1, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 2, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 3, with: date, setSharedData: nil)
        defaults.setQuantityWithoutWarning(to: 3)
        XCTAssertEqual(estrogenSchedule.count(), 3)
    }
    
    /// Test the site schedule reflects changes from defaults
    func testSiteSchedule() {
        defaults.setDeliveryMethod(to: "Patches")
        siteSchedule.setName(at: 0, to: "NEW SITE")
        XCTAssert(!siteSchedule.isDefault(usingPatches: true))
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
    }
    
    /// Test the schedule state reflects changes from defaults
    func testScheduleState() {
        defaults.setDeliveryMethod(to: "Patches")
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssert(scheduleState.deliveryMethodChanged)
    }
    
    func testDeliveryMethod() {
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(estrogenSchedule.usingPatches)
        XCTAssertFalse(estrogenSchedule.usingPatches)
        XCTAssertEqual(defaults.getDeliveryMethod(), "Injections")
        defaults.setDeliveryMethod(to: "Patches")
        XCTAssertEqual(defaults.getDeliveryMethod(), "Patches")
        XCTAssert(estrogenSchedule.usingPatches)
        XCTAssert(siteSchedule.usingPatches)
        defaults.setDeliveryMethod(to: "BAD")
        XCTAssertNotEqual(defaults.getDeliveryMethod(), "BAD")
    }
    
    func testTimeInterval() {
        let intervals = PDStrings.PickerData.expirationIntervals
        defaults.setTimeInterval(to: intervals[0])
        XCTAssertEqual(defaults.getTimeInterval(), intervals[0])
        defaults.setTimeInterval(to: "BAD INTERVAL")
        XCTAssertEqual(defaults.getTimeInterval(), intervals[0])
    }
    
    func testSetQuantityWithWarning() {
        defaults.setQuantityWithoutWarning(to: 1)
        let date = Date(timeIntervalSince1970: 0)
        let mock1: () -> () = {}
        let mock2: (Int) -> () = { void in }
        estrogenSchedule.setDate(of: 0, with: date, setSharedData: nil)
        defaults.setQuantityWithWarning(to: 2, oldCount: 4,
                                        cont: mock1,
                                        reset: mock2,
                                        cancel: mock2)
        let actual = defaults.getQuantity()
        XCTAssertEqual(actual, 2)
        
        // TODO: Figure out a way to test for newCount < oldCount
        //
        //
    }
    
    func testSetQuantityWithoutWarning() {
        defaults.setDeliveryMethod(to: "Patches")
        defaults.setQuantityWithoutWarning(to: 1)
        var expected = 1
        XCTAssertEqual(defaults.getQuantity(), expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), expected)

        defaults.setQuantityWithoutWarning(to: 2)
        expected = 2
        XCTAssertEqual(defaults.getQuantity(), expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), expected)

        defaults.setQuantityWithoutWarning(to: 3)
        expected = 3
        XCTAssertEqual(defaults.getQuantity(), expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), 3)

        defaults.setQuantityWithoutWarning(to: 4)
        expected = 4
        XCTAssertEqual(defaults.getQuantity(), 4)
        XCTAssertEqual(estrogenSchedule.quantity, 4)
        XCTAssertEqual(estrogenSchedule.count(), 4)
        
        defaults.setQuantityWithoutWarning(to: 400)
        var actual = defaults.getQuantity()
        XCTAssertEqual(actual, 4)
        
        // Should not allow to exceed 4 while in Patches modes
        defaults.setQuantityWithoutWarning(to: 6)
        actual = defaults.getQuantity()
        XCTAssertNotEqual(actual, 6)
        
        defaults.setDeliveryMethod(to: "Injections")
        defaults.setQuantityWithoutWarning(to: 6)
        actual = defaults.getQuantity()
        XCTAssertEqual(actual, 1)
    }
    
    func testNotificationMinutes() {
        defaults.setNotificationMinutesBefore(to: 30)
        let actual = defaults.getNotificationMinutesBefore()
        XCTAssertEqual(actual, 30)
    }
    
    func testNotify() {
        defaults.setNotify(to: true)
        XCTAssert(defaults.notify())
    }
    
    func testMentionedDisclaimer() {
        defaults.setMentionedDisclaimer(to: true)
        XCTAssert(defaults.mentionedDisclaimer())
    }
    
    func testSiteIndex() {
        defaults.setSiteIndex(to: 2)
        XCTAssertEqual(defaults.getSiteIndex(), 2)
        defaults.setSiteIndex(to: 10)
        XCTAssertEqual(defaults.getSiteIndex(), 2)
        defaults.setSiteIndex(to: -1)
        XCTAssertEqual(defaults.getSiteIndex(), 2)
    }

    // Other public
    
    func testUsingPatches() {
        defaults.setDeliveryMethod(to: "Patches")
        XCTAssert(defaults.usingPatches())
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(defaults.usingPatches())
    }

    func testIsAccpetable() {
        XCTAssert(defaults.isAcceptable(count: 1, max: 4))
        XCTAssert(defaults.isAcceptable(count: 2, max: 4))
        XCTAssert(defaults.isAcceptable(count: 3, max: 4))
        XCTAssert(defaults.isAcceptable(count: 4, max: 4))
        XCTAssertFalse(defaults.isAcceptable(count: -1, max: 4))
        XCTAssertFalse(defaults.isAcceptable(count: 5, max: 4))
    }
}
