//
//  PatchComparable.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/10/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PatchDay

class PatchComparable: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        SettingsDefaultsController.setNumberOfPatches(to: "3")
        let oldDate = Date(timeIntervalSince1970: 0)
        PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: "custom")
        PatchDataController.setPatch(patchIndex: 1, patchDate: oldDate, location: "custom")
        XCTAssert(PatchDataController.getPatch(index: 0)!.getDatePlaced()! > PatchDataController.getPatch(index: 1)!.getDatePlaced()!)
        XCTAssert(PatchDataController.getPatch(index: 0)! > PatchDataController.getPatch(index: 1)!)
        XCTAssert(PatchDataController.getPatch(index: 1)! < PatchDataController.getPatch(index: 0)!)
        PatchDataController.setPatchLocation(patchIndex: 2, with: "custom")
        XCTAssert(PatchDataController.getPatch(index: 1)! < PatchDataController.getPatch(index: 2)!)
        
    }
    
}
