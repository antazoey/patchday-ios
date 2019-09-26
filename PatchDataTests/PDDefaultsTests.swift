//
//  PDDefaultsTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 12/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable 

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
        defaults.setDeliveryMethod(to: .Patches)
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
        let date = Date.createDefaultDate()
        estrogenSchedule.setDate(of: 0, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 1, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 2, with: date, setSharedData: nil)
        estrogenSchedule.setDate(of: 3, with: date, setSharedData: nil)
        defaults.setQuantityWithoutWarning(to: 3)
        XCTAssertEqual(estrogenSchedule.count(), 3)
    }
    
    /// Test the site schedule reflects changes from defaults
    func testSiteSchedule() {
        defaults.setDeliveryMethod(to: .Patches)
        siteSchedule.rename(at: 0, to: "NEW SITE")
        XCTAssert(!siteSchedule.isDefault(deliveryMethod: .Patches))
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Injections))
    }
    
    /// Test the schedule state reflects changes from defaults
    func testPDState() {
        defaults.setDeliveryMethod(to: .Patches)
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssert(state.deliveryMethodChanged)
    }
    
    func testThatDeliveryMethodSetsDefaults() {
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssertEqual(defaults.deliveryMethod.value, DeliveryMethod.Injections)
        defaults.setDeliveryMethod(to: .Patches)
        XCTAssertEqual(defaults.deliveryMethod.value, DeliveryMethod.Patches)
    }
    
    func testDeliveryMethodSideEffects() {
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssertEqual(estrogenSchedule.count(), 1)
        XCTAssertEqual(estrogenSchedule.quantity, 1)
        XCTAssertEqual(siteSchedule.count(), 6)
        defaults.setDeliveryMethod(to: .Patches)
        let deliv = defaults.deliveryMethod.value
        XCTAssertEqual(deliv, DeliveryMethod.Patches)
        XCTAssert(estrogenSchedule.deliveryMethod == .Patches)
        XCTAssert(siteSchedule.deliveryMethod == .Patches)
        XCTAssertEqual(estrogenSchedule.count(), 3)
        XCTAssertEqual(estrogenSchedule.quantity, 3)
        XCTAssertEqual(siteSchedule.count(), 4)
        // ignore resets
        defaults.setDeliveryMethod(to: .Injections, shouldReset: false)
        XCTAssertEqual(estrogenSchedule.count(), 3)
        XCTAssertEqual(estrogenSchedule.quantity, 3)
        XCTAssertEqual(siteSchedule.count(), 4)
    }
    
    func testTimeInterval() {
        defaults.set(&defaults.expirationInterval, to: ExpirationInterval.TwiceAWeek)
        let t = defaults.expirationInterval.value
        XCTAssertEqual(t, ExpirationInterval.TwiceAWeek)
    }
    
    func testSetQuantityWithWarning() {
        defaults.setQuantityWithoutWarning(to: 1)
        let date = Date.createDefaultDate()
        let mock: (Int) -> () = { void in }
        estrogenSchedule.setDate(of: 0, with: date, setSharedData: nil)
        defaults.setQuantityWithWarning(to: Quantity.Two, oldQ: Quantity.Four,
                                        reset: mock,
                                        cancel: mock)
        let actual = defaults.quantity.value
        XCTAssertEqual(actual, Quantity.Two)
        
        // TODO: Figure out a way to test for newCount < oldCount
        //
        //
    }
    
    func testSetQuantityWithoutWarning() {
        defaults.setDeliveryMethod(to: .Patches)
        defaults.setQuantityWithoutWarning(to: 1)
        XCTAssertEqual(defaults.quantity.value, Quantity.One)
        XCTAssertEqual(estrogenSchedule.quantity, 1)
        XCTAssertEqual(estrogenSchedule.count(), 1)

        defaults.setQuantityWithoutWarning(to: 2)
        XCTAssertEqual(defaults.quantity.value, Quantity.Two)
        XCTAssertEqual(estrogenSchedule.quantity, 2)
        XCTAssertEqual(estrogenSchedule.count(), 2)

        defaults.setQuantityWithoutWarning(to: 3)
        XCTAssertEqual(defaults.quantity.value, Quantity.Three)
        XCTAssertEqual(estrogenSchedule.quantity, 3)
        XCTAssertEqual(estrogenSchedule.count(), 3)

        defaults.setQuantityWithoutWarning(to: 4)
        XCTAssertEqual(defaults.quantity.value, Quantity.Four)
        XCTAssertEqual(estrogenSchedule.quantity, 4)
        XCTAssertEqual(estrogenSchedule.count(), 4)
        
        defaults.setQuantityWithoutWarning(to: 400)
        XCTAssertEqual(defaults.quantity.value.rawValue, 4)
        
        defaults.setDeliveryMethod(to: .Injections)
        defaults.setQuantityWithoutWarning(to: 6)
        XCTAssertEqual(defaults.quantity.value, Quantity.One)
    }
    
    func testNotificationMinutes() {
        defaults.set(&defaults.notificationsMinutesBefore, to: 30)
        let actual = defaults.notificationsMinutesBefore
        XCTAssertEqual(actual.value, 30)
    }
    
    func testNotify() {
        defaults.set(&defaults.notifications, to: true)
        let notify = defaults.notifications
        XCTAssert(notify.value)
    }
    
    func testMentionedDisclaimer() {
        defaults.set(&defaults.mentionedDisclaimer, to: true)
        let mentioned = defaults.mentionedDisclaimer
        XCTAssert(mentioned.value)
    }
    
    func testSiteIndex() {
        defaults.setSiteIndex(to: 2)
        XCTAssertEqual(defaults.siteIndex.value, 2)
        defaults.setSiteIndex(to: 10)
        XCTAssertEqual(defaults.siteIndex.value, 2)
        defaults.setSiteIndex(to: -1)
        XCTAssertEqual(defaults.siteIndex.value, 2)
        defaults.setSiteIndex(to: 3)
        XCTAssertEqual(defaults.siteIndex.value, 3)
    }

    // Other public
    
    func testSetDeliveryMethod() {
        defaults.setDeliveryMethod(to: .Patches)
        XCTAssert(defaults.deliveryMethod.value == .Patches)
        defaults.setDeliveryMethod(to: .Injections)
        XCTAssert(defaults.deliveryMethod.value == .Injections)
    }
}
