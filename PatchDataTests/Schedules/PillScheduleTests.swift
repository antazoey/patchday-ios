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
    private var util: PillScheduleTestsUtil!
    
    private let newPill = MockPill()
    
    override func setUp() {
        mockStore = MockPillStore()
        mockDataSharer = MockPillDataSharer()
        util = PillScheduleTestsUtil(mockStore, mockDataSharer)
    }
    
    // MARK: - Setup helpers
    
    private func setUpPills() {
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Working)
    }
    
    private func setUpPills(_ mockPills: [MockPill]) {
        mockStore.getStoredCollectionReturnValues = [mockPills]
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Working)
    }
    
    private func setUpPills(insertPillFactory: (() -> MockPill)?) {
        mockStore.newObjectFactory = insertPillFactory
        setUpPills()
    }

    // MARK: - Tests

    public func testInit_resetsToPillCountToTwo() {
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Initial)
        XCTAssertEqual(2, pills.count)
    }
    
    public func testInit_whenGivenInitialState_resetsPills() {
        pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Initial)
        let pillOne = pills.at(0)! as! MockPill
        let pillTwo = pills.at(1)! as! MockPill
        XCTAssert(pillOne.resetCallCount == 1 && pillTwo.resetCallCount == 1)  // a.k.a pills are default
    }

    public func testNextDue_returnsPillsWithOldestDueDate() {
        let mockPills = util.createThreePills()
        
        mockPills[0].due = Date()
        mockPills[1].due = Date(timeInterval: -10000, since: mockPills[0].due)
        mockPills[2].due = Date()
        
        setUpPills(mockPills)
        
        let expected = mockPills[1].id
        let actual = pills.nextDue!.id
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextDue_whenCountIsZero_returnsNil() {
        setUpPills()
        XCTAssertNil(pills.nextDue)
    }
    
    public func testTotalDue_returnsTotalPillsDue() {
        let mockPills = util.createThreePills()
        
        mockPills[0].isDue = true
        mockPills[1].isDue = true
        mockPills[2].isDue = false
        
        setUpPills(mockPills)
        
        let expected = 2
        let actual = pills.totalDue
        XCTAssertEqual(expected, actual)
    }
    
    public func testTotalDue_whenCountIsZero_returnsZero() {
        setUpPills()
        let expected = 0
        let actual = pills.totalDue
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenStoreReturnsNil_doesNotIncreasePillCount() {
        setUpPills(insertPillFactory: nil)
        setUpPills()
        pills.insertNew(onSuccess: nil)
        let expected = 0
        let actual = pills.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenStoreReturnsPill_increasesCount() {
        setUpPills()
        pills.insertNew(onSuccess: nil)
        let expected = 1
        let actual = pills.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenStoreReturnsPill_containsPillInAll() {
        setUpPills(insertPillFactory: { () in self.newPill })
        pills.insertNew(onSuccess: nil)
        XCTAssert(pills.all.contains(where: { $0.id == newPill.id }))
    }
    
    public func testInsertNew_whenStoreReturnsPills_savesChanges() {
        setUpPills(insertPillFactory: { () in self.newPill })
        pills.insertNew(onSuccess: nil)
        XCTAssert(util.didSave(with: [newPill]))
    }
    
    public func testInsertNew_whenStoreReturnsPills_callsCompletion() {
        setUpPills(insertPillFactory: { () in self.newPill })
        var wasCalled = false
        let onSuccess = { () in wasCalled = true }
        pills.insertNew(onSuccess: onSuccess)
        XCTAssert(wasCalled)
    }
    
    public func testInsertNew_whenStoreReturnsPills_sharesDataForNextDue() {
        self.newPill.id = UUID()
        setUpPills(insertPillFactory: { () in self.newPill })
        pills.insertNew(onSuccess: nil)
        XCTAssert(util.nextPillDueWasShared(pills))
    }
    
    public func testDelete_whenPillExists_removesPill() {
        let mockPills = util.createThreePills()
        let testId = UUID()
        mockPills[0].id = testId
        setUpPills(mockPills)
        pills.delete(at: 0)
        XCTAssertNil(pills.get(by: testId))
    }
    
    public func testDelete_whenPillExists_sharesDataForNextDue() {
        let mockPills = util.createThreePills()
        setUpPills(mockPills)
        pills.delete(at: 0)
        let expected = pills.nextDue?.id
        let actual = mockDataSharer.shareCallArgs[0].id
        XCTAssertEqual(expected, actual)
    }
    
    public func testDelete_deletesThePillFromTheStore() {
        let mockPills = util.createThreePills()
        let testId = UUID()
        mockPills[0].id = testId
        setUpPills(mockPills)
        pills.delete(at: 0)
        let actual = mockStore.deleteCallArgs[0].id
        let expected = testId
        XCTAssertEqual(expected, actual)
    }
    
    public func testReset_resetsToPillCountToTwo() {
        setUpPills(util.createThreePills())
        pills.reset()
        XCTAssertEqual(2, pills.count)
    }
    
    public func testReset_whenGivenInitialState_resetsPills() {
        setUpPills(util.createThreePills())
        pills.reset()
        let pillOne = pills.at(0)! as! MockPill
        let pillTwo = pills.at(1)! as! MockPill
        XCTAssert(pillOne.resetCallCount == 1 && pillTwo.resetCallCount == 1)  // a.k.a pills are default
    }
    
    public func testReset_savesChanges() {
        var i = 0
        let mockPillOne = MockPill()
        let mockPillTwo = MockPill()
        mockStore.newObjectFactory = {
            let r = i == 0 ? mockPillOne : mockPillTwo
            i += 1
            return r
        }
        setUpPills(util.createThreePills())
        pills.reset()
        
        // The most recent call
        XCTAssert(util.didSave(with: [mockPillOne, mockPillTwo]))
    }
    
    public func testAt_whenPillExists_returnsPill() {
        setUpPills(util.createThreePills())
        XCTAssertNotNil(pills.at(0))
    }
    
    public func testAt_whenPillDoesNotExist_returnsNil() {
        setUpPills(util.createThreePills())
        XCTAssertNil(pills.at(3))
    }
    
    public func testGet_whenPillExists_returnsPill() {
        let mockPills = util.createThreePills()
        setUpPills(mockPills)
        XCTAssertNotNil(pills.get(by: mockPills[0].id))
    }
    
    public func testGet_whenPillDoesNotExist_returnsNil() {
        setUpPills(util.createThreePills())
        XCTAssertNil(pills.get(by: UUID()))
    }
    
    public func testSet_whenPillExistsAndSettingByIndex_updatesPill() {
        var attributes = PillAttributes()
        let testDate = Date()
        attributes.name = "New Name"
        attributes.time1 = testDate
        setUpPills(util.createThreePills())
        pills.set(at: 0, with: attributes)
        let pill = pills.at(0) as! MockPill

        XCTAssert(pill.setCallArgs.contains(where:
            { (_ a: PillAttributes) in a.name == "New Name" && a.time1 == testDate
        }))
    }
    
    public func testSet_whenPillExistsAndSettingByIndex_savesChanges() {
        var attributes = PillAttributes()
        let testDate = Date()
        attributes.name = "New Name"
        attributes.time1 = testDate
        let mockPills = util.createThreePills()
        setUpPills(mockPills)
        pills.set(at: 0, with: attributes)
        XCTAssert(util.didSave(with: [mockPills[0]]))
    }
    
    public func testSet_whenPillExistsAndSettingByIndex_sharedNextPillDue() {
        var attributes = PillAttributes()
        let testDate = Date()
        attributes.name = "New Name"
        attributes.time1 = testDate
        let mockPills = util.createThreePills()
        setUpPills(mockPills)
        pills.set(at: 0, with: attributes)
        XCTAssert(util.didSave(with: [mockPills[0]]))
    }
    
    public func testSet_whenPillExistsAndSettingById_updatesPill() {
        var attributes = PillAttributes()
        let testDate = Date()
        attributes.name = "New Name"
        attributes.time1 = testDate
        let mockPills = util.createThreePills()
        let idToSet = mockPills[0].id
        setUpPills(mockPills)
        
        pills.set(by: idToSet, with: attributes)
        let pill = pills.get(by: idToSet) as! MockPill

        XCTAssert(pill.setCallArgs.contains(where:
            { (_ a: PillAttributes) in a.name == "New Name" && a.time1 == testDate
        }))
    }
    
    public func testSet_whenPillExistsAndSettingById_savesChanges() {
        var attributes = PillAttributes()
        let testDate = Date()
        attributes.name = "New Name"
        attributes.time1 = testDate
        let mockPills = util.createThreePills()
        let idToSet = mockPills[0].id
        setUpPills(mockPills)
        
        pills.set(by: idToSet, with: attributes)
        XCTAssert(util.didSave(with: [mockPills[0]]))
    }
}
