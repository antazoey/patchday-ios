//
//  PillScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/15/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class PillScheduleTests: XCTestCase {

    private var mockStore: MockPillStore!
    private var mockDataSharer: MockPillDataSharer!
    private var pills: PillSchedule!
    
    override func setUp() {
        mockStore = MockPillStore()
        mockDataSharer = MockPillDataSharer()
    }
    
    private func setUpPills() -> [MockPill] {
        let pill1 = MockPill()
        let pill2 = MockPill()
        let pill3 = MockPill()
        
        pill1.lastTaken = Date(timeInterval: -10000, since: Date())
        pill1.timesaday = 1
        pill1.name = "Pill-1"
        pill1.time1 = Date()
        pill2.lastTaken = Date(timeIntervalSince1970: 1000)
        pill2.timesaday = 2
        pill2.name = "Pill-2"
        pill2.time1 = Date(timeInterval: -1000, since: Date())
        pill3.lastTaken = Date(timeIntervalSince1970: 100000)
        pill3.timesaday = 1
        pill3.name = "Pill-3"
        pill3.lastTaken = Date(timeInterval: -10000, since: Date())
        
        let mockPills = [pill1, pill2, pill3]
        
        mockStore.getStoredCollectionReturnValues = [mockPills]
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Working)
        return mockPills
    }
    
    private func assertPillsAreDefault() {
        XCTAssert(pills.count == 2)
        
        let pillOne = pills.at(0)! as! MockPill
        let pillTwo = pills.at(1)! as! MockPill
        
        XCTAssert(pillOne.resetCallCount == 1)
        XCTAssert(pillTwo.resetCallCount == 1)
    }
    
    public func testInit_whenGivenInitialState_resetsToDefaultPills() {
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Initial)
        assertPillsAreDefault()
    }

    public func testNextDue_returnsPillThatIsNextDue() {
        let mockPills = setUpPills()  // The first pill from here is due
        let expected = mockPills[0].id
        let actual = pills.nextDue!.id
        XCTAssertEqual(expected, actual)
    }
}
