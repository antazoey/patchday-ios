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


class HormoneScheduleTests: XCTestCase {

    private var mockBroadcaster: MockHormoneDataBroadcaster!
    private var mockStore: MockHormoneStore!
    private var state: PDState!
    private var mockDefaults: MockUserDefaultsWriter!
    private var hormones: HormoneSchedule!

    override func setUp() {
        super.setUp()
        mockBroadcaster = MockHormoneDataBroadcaster()
        mockStore = MockHormoneStore()
        state = PDState()
        mockDefaults = MockUserDefaultsWriter()
        setUpHormones()
    }
    
    private func setUpHormones() {
        hormones = HormoneSchedule(
            hormoneDataBroadcaster: mockBroadcaster,
            store: mockStore,
            state: state,
            defaults: mockDefaults
        )
    }
    
    func testNext_WhenThereAreNoHormones_ReturnsNil() {
        XCTAssertNil(hormones.next)
    }
    
    func testNext_WhenThereAreHormones_ReturnsHormonesWithOldestDate() {
        let hormone1 = MockHormone()
        let hormone2 = MockHormone()
        let hormone3 = MockHormone()
        
        hormone1.date = Date()
        hormone2.date = Date(timeIntervalSinceNow: -5000)  // Oldest
        hormone3.date = Date(timeIntervalSinceNow: -1000)
        
        mockStore.getStoredHormonesReturnValues = [[hormone1, hormone2, hormone3]]
        setUpHormones()
        
        let actual = hormones.next
        let expected = hormone2
        XCTAssertEqual(expected.id, actual?.id)
    }
}
