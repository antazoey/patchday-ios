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
    
    typealias Controller = PDDefaults
    
    override func setUp() {
        super.setUp()
        Controller.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetAndSetDeliveryMethod() {
        Controller.setDeliveryMethod(to: "Injections")
        XCTAssertEqual(Controller.getDeliveryMethod(), "Injections")
        Controller.setDeliveryMethod(to: "Patches")
        XCTAssertEqual(Controller.getDeliveryMethod(), "Patches")
        Controller.setDeliveryMethod(to: "BAD")
        XCTAssertNotEqual(Controller.getDeliveryMethod(), "BAD")
    }
    
    func testSetQuantityWithoutWarning() {
        Controller.setDeliveryMethod(to: "Patches")
        Controller.setQuantityWithoutWarning(to: 1)
        var actual = Controller.getQuantity()
        XCTAssertEqual(actual, 1)

        Controller.setQuantityWithoutWarning(to: 2)
        actual = Controller.getQuantity()
        XCTAssertEqual(actual, 2)

        Controller.setQuantityWithoutWarning(to: 3)
        actual = Controller.getQuantity()
        XCTAssertEqual(actual, 3)

        Controller.setQuantityWithoutWarning(to: 4)
        actual = Controller.getQuantity()
        XCTAssertEqual(actual, 4)
        
        Controller.setQuantityWithoutWarning(to: 400)
        actual = Controller.getQuantity()
        XCTAssertEqual(actual, 4)
        
        // Should not allow to exceed 4 while in Patches modes
        Controller.setQuantityWithoutWarning(to: 6)
        actual = Controller.getQuantity()
        XCTAssertNotEqual(actual, 6)
        
        PDDefaults.setDeliveryMethod(to: "Injections")
        Controller.setQuantityWithoutWarning(to: 6)
        actual = Controller.getQuantity()
        XCTAssertEqual(actual, 6)
    }

    func testSwitchDeliveryMethods() {
        Controller.setDeliveryMethod(to: "Patches")
        let countBefore = Controller.getQuantity()
        let methodBefore = Controller.getDeliveryMethod()
        Controller.switchDeliveryMethod()
        let methodAfter = Controller.getDeliveryMethod()
        let countAfter = Controller.getQuantity()
        XCTAssertNotEqual(methodBefore, methodAfter)
        XCTAssertNotEqual(countBefore, countAfter)
    }
    
    // Other public
    
    func testUsingPatches() {
        Controller.setDeliveryMethod(to: "Patches")
        XCTAssert(Controller.usingPatches())
        Controller.setDeliveryMethod(to: "Injections")
        XCTAssertFalse(Controller.usingPatches())
    }

    func testIsAccpetable() {
        XCTAssert(Controller.isAcceptable(count: 1, max: 4))
        XCTAssert(Controller.isAcceptable(count: 2, max: 4))
        XCTAssert(Controller.isAcceptable(count: 3, max: 4))
        XCTAssert(Controller.isAcceptable(count: 4, max: 4))
        XCTAssertFalse(Controller.isAcceptable(count: -1, max: 4))
        XCTAssertFalse(Controller.isAcceptable(count: 5, max: 4))
    }
}
