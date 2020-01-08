//
//  HormoneScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.


import XCTest
import PDKit
import PDMock

@testable
import PatchData


public class hormoneScheduleTests: XCTestCase {

    private var mockBroadcaster: MockHormoneDataBroadcaster
    private var mockData: MockPatchData
    private var state: PDState
    private var mockDefaults: MockUserDefaultsWriter
    private var hormones: HormoneSchedule

    override func setUp() {
        super.setUp()
        broadcaster = MockHormoneDataBroadcaster()
        mockData = MockPatchData()
        state = PDState()
        mockDefaults = MockUserDefaultsWriteR()
        hormones = HormoneSchedule(
            hormoneDataBroadcaster: broadcaster, coreDataStack: mockData, state: state, defaults: mockDefaults
        )
    }
    
    func testTest() {
        XCTAssertTrue(true)
    }
}
