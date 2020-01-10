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
    
    private func setUpHormones(_ mockHormones: [MockHormone]=[]) {
        mockStore.getStoredHormonesReturnValues = [mockHormones]
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
    
    func testNext_whenThereAreHormones_returnsHormonesWithOldestDate() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].date = Date()
        mockHormones[1].date = Date(timeIntervalSinceNow: -5000)  // Oldest
        mockHormones[2].date = Date(timeIntervalSinceNow: -1000)
        
        setUpHormones(mockHormones)
        
        let expected = mockHormones[1]
        let actual = hormones.next
        XCTAssertEqual(expected.id, actual?.id)
    }
    
    func testTotalExpired_returnsCountOfHormonesExpired() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].isExpired = true
        mockHormones[1].isExpired = true
        mockHormones[2].isExpired = false
        
        setUpHormones(mockHormones)
        
        let expected = 2
        let actual = hormones.totalExpired
        XCTAssertEqual(expected, actual)
    }
    
    func testInsertNew_whenStoreReturnsNil_doesNotIncreaseHormoneCount() {
        let mockHormones = MockHormone.createList(count: 3)
        setUpHormones(mockHormones)
        
        hormones.insertNew()
        
        let expected = 3
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }
    
    func testInsertNew_whenStoreReturnsHormone_increasesCount() {
        let mockHormones = MockHormone.createList(count: 3)
        let newHormone = MockHormone()
        setUpHormones(mockHormones)
        mockStore.createNewHormoneReturnValues = [newHormone]
        hormones.insertNew()
        
        let expected = 4
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }
    
    func testInsertNew_whenStoreReturnsHormone_appendsNewSite() {
        let mockHormones = MockHormone.createList(count: 3)
        let newHormone = MockHormone()
        setUpHormones(mockHormones)
        mockStore.createNewHormoneReturnValues = [newHormone]
        hormones.insertNew()
        
        XCTAssertTrue(hormones.all.contains(where: { $0.id == newHormone.id }))
    }
    
    func testInsertNew_whenStoreReturnsHormone_maintainsOrder() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].date = Date()
        mockHormones[1].date = Date(timeIntervalSinceNow: -5000)  // Original oldest
        mockHormones[2].date = Date(timeIntervalSinceNow: -1000)
        
        let newHormone = MockHormone()
        newHormone.date = Date(timeIntervalSinceNow: -999999)  // New oldest
        
        setUpHormones(mockHormones)
        mockStore.createNewHormoneReturnValues = [newHormone]
        hormones.insertNew()
        
        let expected = newHormone
        let actual = hormones.all.first
        XCTAssertEqual(expected.id, actual?.id)
    }
    
    func testSort_sortsHormones() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].date = Date()
        mockHormones[1].date = Date(timeIntervalSinceNow: -5000)  // Original oldest
        mockHormones[2].date = Date(timeIntervalSinceNow: -1000)
        
        setUpHormones(mockHormones)
        hormones.sort()
        
        XCTAssertTrue(
            hormones.all[0].date == mockHormones[1].date &&
            hormones.all[1].date == mockHormones[2].date &&
            hormones.all[2].date == mockHormones[0].date
        )
    }
}
