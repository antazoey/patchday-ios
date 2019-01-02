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
    
    override func setUp() {
        super.setUp()
        PDDefaults.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetEstrogenSchedule() {
        // Test that side effects work via the removal of
        // patches after decreasing the Quantity in PDDefaults
        // and that it is the same ref
        PDDefaults.setQuantityWithoutWarning(to: 4)
        let estrogenSchedule = EstrogenSchedule()
        let date = Date(timeIntervalSince1970: 0)
        estrogenSchedule.setDate(of: 0, with: date)
        estrogenSchedule.setDate(of: 1, with: date)
        estrogenSchedule.setDate(of: 2, with: date)
        estrogenSchedule.setDate(of: 3, with: date)
        PDDefaults.setEstrogenSchedule(estrogenSchedule)
        PDDefaults.setQuantityWithoutWarning(to: 3)
        XCTAssertEqual(estrogenSchedule.count(), 3)
    }
    
    func testSetSiteSchedule() {
        // Test that side effects work via site schedule resetting,
        // and that it's the same ref
        PDDefaults.setDeliveryMethod(to: "Patches")
        let schedule = SiteSchedule()
        schedule.setName(at: 0, to: "NEW SITE")
        PDDefaults.setSiteSchedule(schedule)
        XCTAssert(!schedule.isDefault(usingPatches: true))
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssert(schedule.isDefault(usingPatches: false))
    }
    
    func testSetScheduleState() {
        // Test that side effects work via
        // state variables, and that it's the same ref
        let state = ScheduleState()
        PDDefaults.setScheduleState(state)
        PDDefaults.setDeliveryMethod(to: "Patches")
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssert(state.deliveryMethodChanged)
    }
    
    func testDeliveryMethod() {
        let estroSched = EstrogenSchedule()
        let siteSched = SiteSchedule()
        PDDefaults.setEstrogenSchedule(estroSched)
        PDDefaults.setSiteSchedule(siteSched)
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(estroSched.usingPatches)
        XCTAssertFalse(siteSched.usingPatches)
        XCTAssertEqual(PDDefaults.getDeliveryMethod(), "Injections")
        PDDefaults.setDeliveryMethod(to: "Patches")
        XCTAssertEqual(PDDefaults.getDeliveryMethod(), "Patches")
        XCTAssert(estroSched.usingPatches)
        XCTAssert(siteSched.usingPatches)
        PDDefaults.setDeliveryMethod(to: "BAD")
        XCTAssertNotEqual(PDDefaults.getDeliveryMethod(), "BAD")
    }
    
    func testTimeInterval() {
        let intervals = PDStrings.PickerData.expirationIntervals
        PDDefaults.setTimeInterval(to: intervals[0])
        XCTAssertEqual(PDDefaults.getTimeInterval(), intervals[0])
        PDDefaults.setTimeInterval(to: "BAD INTERVAL")
        XCTAssertEqual(PDDefaults.getTimeInterval(), intervals[0])
    }
    
    func testSetQuantityWithWarning() {
        PDDefaults.setQuantityWithoutWarning(to: 1)
        let schedule = EstrogenSchedule()
        let date = Date(timeIntervalSince1970: 0)
        schedule.setDate(of: 0, with: date)
        PDDefaults.setEstrogenSchedule(schedule)
        let button = UIButton()
        PDDefaults.setQuantityWithWarning(to: 2, oldCount: 4, countButton: button) {
            newCount in
        }
        let actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 2)
        
        // TODO: Figure out a way to test for newCount < oldCount
        //
        //
    }
    
    func testSetQuantityWithoutWarning() {
        PDDefaults.setDeliveryMethod(to: "Patches")
        PDDefaults.setQuantityWithoutWarning(to: 1)
        var actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 1)

        PDDefaults.setQuantityWithoutWarning(to: 2)
        actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 2)

        PDDefaults.setQuantityWithoutWarning(to: 3)
        actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 3)

        PDDefaults.setQuantityWithoutWarning(to: 4)
        actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 4)
        
        PDDefaults.setQuantityWithoutWarning(to: 400)
        actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 4)
        
        // Should not allow to exceed 4 while in Patches modes
        PDDefaults.setQuantityWithoutWarning(to: 6)
        actual = PDDefaults.getQuantity()
        XCTAssertNotEqual(actual, 6)
        
        PDDefaults.setDeliveryMethod(to: "Injections")
        PDDefaults.setQuantityWithoutWarning(to: 6)
        actual = PDDefaults.getQuantity()
        XCTAssertEqual(actual, 1)
    }
    
    func testNotificationMinutes() {
        PDDefaults.setNotificationMinutesBefore(to: 30)
        let actual = PDDefaults.getNotificationMinutesBefore()
        XCTAssertEqual(actual, 30)
    }
    
    func testNotify() {
        PDDefaults.setNotify(to: true)
        XCTAssert(PDDefaults.notify())
    }
    
    func testMentionedDisclaimer() {
        PDDefaults.setMentionedDisclaimer(to: true)
        XCTAssert(PDDefaults.mentionedDisclaimer())
    }
    
    func testSiteIndex() {
        let siteSchedule = SiteSchedule()
        PDDefaults.setSiteSchedule(siteSchedule)
        PDDefaults.setSiteIndex(to: 2)
        XCTAssertEqual(PDDefaults.getSiteIndex(), 2)
        PDDefaults.setSiteIndex(to: 10)
        XCTAssertEqual(PDDefaults.getSiteIndex(), 2)
        PDDefaults.setSiteIndex(to: -1)
        XCTAssertEqual(PDDefaults.getSiteIndex(), 2)
    }

    // Other public
    
    func testUsingPatches() {
        PDDefaults.setDeliveryMethod(to: "Patches")
        XCTAssert(PDDefaults.usingPatches())
        PDDefaults.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(PDDefaults.usingPatches())
    }

    func testIsAccpetable() {
        XCTAssert(PDDefaults.isAcceptable(count: 1, max: 4))
        XCTAssert(PDDefaults.isAcceptable(count: 2, max: 4))
        XCTAssert(PDDefaults.isAcceptable(count: 3, max: 4))
        XCTAssert(PDDefaults.isAcceptable(count: 4, max: 4))
        XCTAssertFalse(PDDefaults.isAcceptable(count: -1, max: 4))
        XCTAssertFalse(PDDefaults.isAcceptable(count: 5, max: 4))
    }
}
