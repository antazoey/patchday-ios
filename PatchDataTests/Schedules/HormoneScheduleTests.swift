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
        mockStore.createNewHormoneReturnValue = nil
        setUpHormones()
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
        mockStore.createNewHormoneReturnValue = nil
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
        mockStore.createNewHormoneReturnValue = newHormone
        hormones.insertNew()
        let expected = 4
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }
    
    func testInsertNew_whenStoreReturnsHormone_appendsNewSite() {
        let mockHormones = MockHormone.createList(count: 3)
        let newHormone = MockHormone()
        setUpHormones(mockHormones)
        mockStore.createNewHormoneReturnValue = newHormone
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
        mockStore.createNewHormoneReturnValue = newHormone
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
    
    func testResetIfEmpty_ifHormonesNotEmpty_returnsCount() {
        let mockHormones = MockHormone.createList(count: 3)
        setUpHormones(mockHormones)
        let expected = mockHormones.count
        let actual = hormones.resetIfEmpty()
        XCTAssertEqual(expected, actual)
    }
    
    func testResetIfEmpty_ifHormonesNotEmpty_doesNotResetSites() {
        let mockHormones = MockHormone.createList(count: 1)
        let unexpectedId = UUID()
        mockHormones[0].id = unexpectedId
        setUpHormones(mockHormones)
        hormones.reset()
        XCTAssert(!hormones.all.contains(where: { $0.id == unexpectedId }))
    }
    
    func testReset_ifDeliveryMethodIsPatches_resetsHormonesCountToThree() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(with: .Patches)
        setUpHormones()
        hormones.reset()
        XCTAssertEqual(3, hormones.count)
    }
    
    func testReset_ifDeliveryMethodIsPatches_returnsThree() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(with: .Patches)
        setUpHormones()
        let actual = hormones.reset()
        XCTAssertEqual(3, actual)
    }
    
    func testReset_ifDeliveryMethodIsInjections_resetsHormonesCountToOne() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(with: .Injections)
        setUpHormones()
        hormones.reset()
        XCTAssertEqual(1, hormones.count)
    }
    
    func testReset_ifDeliveryMethodIsInjections_returnsOnes() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(with: .Injections)
        setUpHormones()
        let actual = hormones.reset()
        XCTAssertEqual(1, actual)
    }
    
    func testReset_ifGivenClosure_callsClosure() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(with: .Injections)
        setUpHormones()
        
        var closureWasCalled = false
        let testClosure = { closureWasCalled = true }
        
        hormones.reset(completion: testClosure)
        
        XCTAssertTrue(closureWasCalled)
    }
    
    func testDeleteAfterIndex_whenIndexGreaterThanCount_doesNotDeleteAnything() {
        let mockHormones = MockHormone.createList(count: 1)
        setUpHormones(mockHormones)
        hormones.delete(after: 1)
        XCTAssertEqual(1, hormones.count)
    }
    
    func testDeleteAfterIndex_whenIndexLessThanCount_deletesAfterIndex() {
        let mockHormones = MockHormone.createList(count: 3)
        setUpHormones(mockHormones)
        hormones.delete(after: 1)
        XCTAssertEqual(2, hormones.count)
    }
    
    func testSaveAll_whenCountIsZero_doesNotCallSave() {
        mockStore.createNewHormoneReturnValue = nil
        setUpHormones()
        hormones.saveAll()
        XCTAssert(mockStore.pushLocalChangesCallArgs.count == 0)
    }
    
    func testDeleteAll_whenCountIsZero_doesNotCallStoreDelete() {
        mockStore.createNewHormoneReturnValue = nil
        setUpHormones()
        hormones.deleteAll()
        XCTAssert(mockStore.deleteCallArgs.count == 0)
    }
    
    func testAt_whenIndexOutOfBound_returnsNil() {
        let mockHormones = MockHormone.createList(count: 1)
        setUpHormones(mockHormones)
        let actual = hormones.at(1)
        XCTAssertNil(actual)
    }
    
    func testAt_whenIndexInBounds_returnsHormone() {
        let mockHormones = MockHormone.createList(count: 2)
        let expectedId = UUID()
        mockHormones[1].id = expectedId
        setUpHormones(mockHormones)
        let actualId = hormones.at(1)?.id
        XCTAssertEqual(expectedId, actualId)
    }
    
    func testGet_returnsIndexForGivenId() {
        let mockHormones = MockHormone.createList(count: 2)
        let expectedId = UUID()
        mockHormones[1].id = expectedId
        setUpHormones(mockHormones)
        let actualId = hormones.get(by: expectedId)?.id
        XCTAssertEqual(expectedId, actualId)
    }
    
    func testSet_whenGivenId_setsDateAndSiteOfHormoneWithGivenId() {
        let mockHormones = MockHormone.createList(count: 1)
        let expectedId = UUID()
        mockHormones[0].id = expectedId
        setUpHormones(mockHormones)
        let testDate = Date()
        let testSite = MockSite()
        testSite.id = UUID()
        hormones.set(for: expectedId, date: testDate, site: testSite, doSave: true)
        XCTAssert(mockHormones[0].date == testDate && mockHormones[0].siteId == testSite.id)
    }
    
    func testSet_whenGivenId_callsPushWithExpectedArgs() {
        let mockHormones = MockHormone.createList(count: 1)
        let testId = UUID()
        mockHormones[0].id = testId
        setUpHormones(mockHormones)
        hormones.set(for: testId, date: Date(), site: MockSite(), doSave: true)
        XCTAssert(
            mockStore.pushLocalChangesCallArgs[0].0[0].id == mockHormones[0].id
            && mockStore.pushLocalChangesCallArgs[0].1
        )
    }
    
    func testSet_whenGivenIndex_setsDateAndSiteOfHormoneAtIndex() {
        let mockHormones = MockHormone.createList(count: 1)
        let expectedId = UUID()
        mockHormones[0].id = expectedId
        setUpHormones(mockHormones)
        let testSite = MockSite()
        testSite.id = UUID()
        let testDate = Date()
        hormones.set(at: 0, date: testDate, site: testSite, doSave: false)
        XCTAssert(mockHormones[0].date == testDate && mockHormones[0].siteId == testSite.id)
    }
    
    func testSet_whenGivenIndex_callsPushWithExpectedArgs() {
        let mockHormones = MockHormone.createList(count: 1)
        let testId = UUID()
        mockHormones[0].id = testId
        setUpHormones(mockHormones)
        hormones.set(at: 0, date: Date(), site: MockSite(), doSave: false)
        XCTAssert(
            mockStore.pushLocalChangesCallArgs[0].0[0].id == mockHormones[0].id
            && !mockStore.pushLocalChangesCallArgs[0].1
        )
    }
    
    func testDate() {
        
    }
}
