//
//  PDDefaultsBaseClassTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 5/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class PDDefaultsBaseClassTests: XCTestCase {
    
    let estrogenSchedule = EstrogenSchedule()
    let siteSchedule = SiteSchedule()
    let pillSchedule = PillSchedule()
    let state = PDState()
    var shared: PDSharedData!
    var alerter: PatchDataAlert!
    
    var defaults: PDDefaults!
    
    override func setUp() {
        shared = PDSharedData(estrogenSchedule: estrogenSchedule,
                              pillSchedule: pillSchedule,
                              siteSchedule: siteSchedule)
        alerter = PatchDataAlert(estrogenSchedule: estrogenSchedule)
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: state,
                              sharedData: shared,
                              alerter: alerter)
    }

    func testSetDeliveryMethod() {
        var deliv = DeliveryMethodUD(with: .Patches)
        XCTAssertEqual(DeliveryMethod.Patches, deliv.value)
        XCTAssertEqual(DeliveryMethodValueHolder.pkey, deliv.rawValue)
        
        defaults.set(&deliv, to: DeliveryMethod.Injections)
        XCTAssertEqual(DeliveryMethod.Injections, deliv.value)
        XCTAssertEqual(DeliveryMethodValueHolder.ikey, deliv.rawValue)
    }
    
    func testSetQuantity() {
        var q = QuantityUD(with: .Four)
        XCTAssertEqual(Quantity.Four, q.value)
        XCTAssertEqual(4, q.rawValue)
        
        defaults.set(&q, to: .One)
        XCTAssertEqual(Quantity.One, q.value)
        XCTAssertEqual(1, q.rawValue)
    }
    
    func testSetExpirationInterval() {
        var x = ExpirationIntervalUD(with: .EveryTwoWeeks)
        XCTAssertEqual(ExpirationInterval.EveryTwoWeeks, x.value)
        XCTAssertEqual(ExpirationIntervalValueHolder.etwKey, x.rawValue)
        
        defaults.set(&x, to: .OnceAWeek)
        XCTAssertEqual(ExpirationInterval.OnceAWeek, x.value)
        XCTAssertEqual(ExpirationIntervalValueHolder.oawKey, x.rawValue)
    }
}
