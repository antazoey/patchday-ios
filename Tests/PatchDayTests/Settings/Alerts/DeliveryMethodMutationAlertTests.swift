//
//  DeliveryMethodMutationAlertTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 3/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class DeliveryMethodMutationAlertTests: XCTestCase {
    func testContinue_setsDeliveryMethod() {
        let mockSdk = MockSDK()
        let tabs = MockTabs()
        let originalQuantity = 1
        let handlers = DeliveryMethodMutationAlertActionHandler(decline: { _, _ in })
        let newMethod = DeliveryMethod.Patches
        let alert = DeliveryMethodMutationAlert(
            sdk: mockSdk,
            tabs: tabs,
            originalDeliveryMethod: .Injections,
            originalQuantity: originalQuantity,
            newDeliveryMethod: newMethod,
            handlers: handlers
        )
        alert.continueHandler()
        let callArgs = (mockSdk.settings as! MockSettings).setDeliveryMethodCallArgs
        if callArgs.count < 1 {
            XCTFail("SetDeliveryMethod was never called")
            return
        }
        XCTAssertEqual(newMethod, callArgs[0])
    }

    func testContinue_setsTabs() {
        let mockSdk = MockSDK()
        let tabs = MockTabs()
        let originalQuantity = 1
        let handlers = DeliveryMethodMutationAlertActionHandler(decline: { _, _ in })
        let newMethod = DeliveryMethod.Patches
        let alert = DeliveryMethodMutationAlert(
            sdk: mockSdk,
            tabs: tabs,
            originalDeliveryMethod: .Injections,
            originalQuantity: originalQuantity,
            newDeliveryMethod: newMethod,
            handlers: handlers
        )
        alert.continueHandler()
        let callArgs = (mockSdk.settings as! MockSettings).setDeliveryMethodCallArgs
        if callArgs.count < 1 {
            XCTFail("SetDeliveryMethod was never called")
            return
        }
        XCTAssertEqual(1, tabs.reflectHormonesCallCount)
    }

    func testDecline_callsHandlerWithOriginalSettings() {
        let mockSdk = MockSDK()
        let tabs = MockTabs()

        var declineCallArgs: [(DeliveryMethod, Int)] = []
        let decline = {
            q, m in declineCallArgs.append((q, m))
        }

        let originalMethod = DeliveryMethod.Injections
        let originalQuantity = 1
        let handlers = DeliveryMethodMutationAlertActionHandler(decline: decline)
        let newMethod = DeliveryMethod.Patches
        let alert = DeliveryMethodMutationAlert(
            sdk: mockSdk,
            tabs: tabs,
            originalDeliveryMethod: originalMethod,
            originalQuantity: originalQuantity,
            newDeliveryMethod: newMethod,
            handlers: handlers
        )
        alert.declineHandler()
        if declineCallArgs.count < 1 {
            XCTFail("Decline handler was not called")
            return
        }
        XCTAssertEqual(originalMethod, declineCallArgs[0].0)
        XCTAssertEqual(originalQuantity, declineCallArgs[0].1)
    }
}
