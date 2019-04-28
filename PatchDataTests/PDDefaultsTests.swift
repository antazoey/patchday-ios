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

    private var estrogenSchedule: EstrogenSchedule!
    private var siteSchedule: SiteSchedule!
    private var state: PDState!
    public var defaults: PDDefaults!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        estrogenSchedule = EstrogenSchedule()
        siteSchedule = SiteSchedule()
        state = PDState()
        siteSchedule.reset()
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: state,
                              sharedData: nil,
                              alerter: nil)
        defaults.setDeliveryMethod(to: "Patches")
        estrogenSchedule.reset() {
            self.defaults.setQuantityWithoutWarning(to: 3)
        }
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
        XCTAssert(!siteSchedule.isDefault(deliveryMethod: .Patches))
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Injections))
    }
    
    /// Test the schedule state reflects changes from defaults
    func testPDState() {
        defaults.setDeliveryMethod(to: "Patches")
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssert(state.deliveryMethodChanged)
    }
    
    func testDeliveryMethod() {
        var d = String()
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(estrogenSchedule.usingPatches)
        XCTAssertFalse(siteSchedule.deliveryMethod == .Patches)
        d = defaults.deliveryMethod
        XCTAssertEqual(d, "Injections")
        XCTAssertEqual(estrogenSchedule.count(), 1)
        XCTAssertEqual(estrogenSchedule.quantity, 1)
        XCTAssertEqual(siteSchedule.count(), 6)
        defaults.setDeliveryMethod(to: "Patches")
        d = defaults.deliveryMethod
        XCTAssertEqual(d, "Patches")
        XCTAssert(estrogenSchedule.usingPatches)
        XCTAssert(siteSchedule.deliveryMethod == .Patches)
        XCTAssertEqual(estrogenSchedule.count(), 3)
        XCTAssertEqual(estrogenSchedule.quantity, 3)
        XCTAssertEqual(siteSchedule.count(), 4)
        defaults.setDeliveryMethod(to: "BAD")
        d = defaults.deliveryMethod
        XCTAssertNotEqual(d, "BAD")
        // ignore resets
        defaults.setDeliveryMethod(to: "Injections", shouldReset: false)
        XCTAssertEqual(estrogenSchedule.count(), 3)
        XCTAssertEqual(estrogenSchedule.quantity, 3)
        XCTAssertEqual(siteSchedule.count(), 4)
    }
    
    func testTimeInterval() {
        var t = String()
        let intervals = PDStrings.PickerData.expirationIntervals
        defaults.setTimeInterval(to: intervals[0])
        t = defaults.timeInterval
        XCTAssertEqual(t, intervals[0])
        defaults.setTimeInterval(to: "BAD INTERVAL")
        t = defaults.timeInterval
        XCTAssertEqual(t, intervals[0])
    }
    
    func testSetQuantityWithWarning() {
        var actual = Int()
        defaults.setQuantityWithoutWarning(to: 1)
        let date = Date(timeIntervalSince1970: 0)
        let mock: (Int) -> () = { void in }
        estrogenSchedule.setDate(of: 0, with: date, setSharedData: nil)
        defaults.setQuantityWithWarning(to: 2, oldCount: 4,
                                        reset: mock,
                                        cancel: mock)
        actual = defaults.quantity
        XCTAssertEqual(actual, 2)
        
        // TODO: Figure out a way to test for newCount < oldCount
        //
        //
    }
    
    func testSetQuantityWithoutWarning() {
        var actual = Int()
        var expected = Int()
        defaults.setDeliveryMethod(to: "Patches")
        defaults.setQuantityWithoutWarning(to: 1)
        expected = 1
        actual = defaults.quantity
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), expected)

        defaults.setQuantityWithoutWarning(to: 2)
        expected = 2
        actual = defaults.quantity
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), expected)

        defaults.setQuantityWithoutWarning(to: 3)
        expected = 3
        actual = defaults.quantity
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(estrogenSchedule.quantity, expected)
        XCTAssertEqual(estrogenSchedule.count(), 3)

        defaults.setQuantityWithoutWarning(to: 4)
        expected = 4
        actual = defaults.quantity
        XCTAssertEqual(actual, 4)
        XCTAssertEqual(estrogenSchedule.quantity, 4)
        XCTAssertEqual(estrogenSchedule.count(), 4)
        
        defaults.setQuantityWithoutWarning(to: 400)
        actual = defaults.quantity
        XCTAssertEqual(actual, 4)
        
        // Should not allow to exceed 4 while in Patches modes
        defaults.setQuantityWithoutWarning(to: 6)
        actual = defaults.quantity
        XCTAssertNotEqual(actual, 6)
        
        defaults.setDeliveryMethod(to: "Injections")
        defaults.setQuantityWithoutWarning(to: 6)
        actual = defaults.quantity
        XCTAssertEqual(actual, 1)
    }
    
    func testNotificationMinutes() {
        defaults.set(&defaults.notificationsMinutesBefore, to: 30, for: .NotificationMinutesBefore)
        let actual = defaults.notificationsMinutesBefore
        XCTAssertEqual(actual, 30)
    }
    
    func testNotify() {
        defaults.set(&defaults.notifications, to: true, for: .Notifications)
        let notify = defaults.notifications
        XCTAssert(notify)
    }
    
    func testMentionedDisclaimer() {
        defaults.set(&defaults.mentionedDisclaimer, to: true, for: .MentionedDisclaimer)
        let mentioned = defaults.mentionedDisclaimer
        XCTAssert(mentioned)
    }
    
    func testSiteIndex() {
        var siteIndex = Int()
        defaults.setSiteIndex(to: 2)
        siteIndex = defaults.siteIndex
        XCTAssertEqual(siteIndex, 2)
        defaults.setSiteIndex(to: 10)
        siteIndex = defaults.siteIndex
        XCTAssertEqual(siteIndex, 2)
        defaults.setSiteIndex(to: -1)
        siteIndex = defaults.siteIndex
        XCTAssertEqual(siteIndex, 2)
    }

    // Other public
    
    func testSetDeliveryMethod() {
        defaults.setDeliveryMethod(to: "Patches")
        XCTAssert(defaults.getDeliveryMethod() == .Patches)
        defaults.setDeliveryMethod(to: PDStrings.PickerData.deliveryMethods[1])
        XCTAssertFalse(defaults.getDeliveryMethod() == .Injections)
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
