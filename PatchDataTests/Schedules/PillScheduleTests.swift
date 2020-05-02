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

	@discardableResult
	private func setUpThreePills() -> [MockPill] {
		let mockPills = util.createThreePills()
		setUpPills(mockPills)
		return mockPills
	}

	private func setUpPills(_ mockPills: [MockPill]) {
		mockStore.getStoredCollectionReturnValues = [mockPills]
		pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Working)
	}

	private func setUpPills(insertPillFactory: (() -> MockPill)?) {
		mockStore.newObjectFactory = insertPillFactory
		setUpPills()
	}

	@discardableResult
	private func setUpThreePillsWithMiddleOneNextDue() -> [MockPill] {
		let mockPills = setUpThreePills()
		mockPills[0].due = Date(timeInterval: 1000, since: Date())
		mockPills[1].due = Date() // next due
		mockPills[2].due = Date(timeInterval: 10000, since: Date())
		return mockPills
	}

	// MARK: - Tests

	public func testInit_resetsToPillCountToTwo() {
		pills = PillSchedule(store: mockStore, pillDataSharer: mockDataSharer, state: .Initial)
		XCTAssertEqual(2, pills.count)
	}

	public func testNextDue_returnsPillsWithOldestDueDate() {
		let mockPills = setUpThreePills()

		mockPills[0].due = Date()
		mockPills[1].due = Date(timeInterval: -10000, since: mockPills[0].due!)
		mockPills[2].due = Date()

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
		XCTAssertNil(pills[testId])
	}

	public func testDelete_whenPillExists_sharesDataForNextDue() {
		setUpThreePills()
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
		setUpThreePills()
		pills.reset()
		XCTAssertEqual(2, pills.count)
	}

	public func testReset_resetsPillTimesadays() {
		setUpThreePills()
		pills.reset()
		XCTAssert(pills[0]!.timesaday == 1 && pills[1]!.timesaday == 1)
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
		setUpThreePills()
		pills.reset()

		// The most recent call
		XCTAssert(util.didSave(with: [mockPillOne, mockPillTwo]))
	}

	public func testSubscript_whenIndexInRange_returnsPill() {
		setUpThreePills()
		XCTAssertNotNil(pills[0])
	}

	public func testSubscript_whenIndexOutOfRange_returnsNil() {
		setUpThreePills()
		XCTAssertNil(pills[3])
	}

	public func testSubscript_whenPillExists_returnsPill() {
		let mockPills = setUpThreePills()
		XCTAssertNotNil(pills[mockPills[0].id])
	}

	public func testSubscript_whenPillDoesNotExist_returnsNil() {
		setUpThreePills()
		XCTAssertNil(pills[UUID()])
	}

	public func testSet_whenPillExistsAndSettingByIndex_updatesPill() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		setUpThreePills()
		pills.set(at: 0, with: attributes)
		let pill = pills[0] as! MockPill

		XCTAssert(pill.setCallArgs.contains(where: { (_ a: PillAttributes) in a.name == "New Name" && a.time1 == testDate
			}))
	}

	public func testSet_whenPillExistsAndSettingByIndex_savesChanges() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		let mockPills = setUpThreePills()
		pills.set(at: 0, with: attributes)
		XCTAssert(util.didSave(with: [mockPills[0]]))
	}

	public func testSet_whenPillExistsAndSettingByIndex_sharedNextPillDue() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		let mockPills = setUpThreePills()
		mockPills[1].due = Date(timeInterval: -10000, since: Date())
		mockPills[1].name = "Next Pill Due"
		pills.set(at: 0, with: attributes)
		XCTAssert(mockDataSharer.shareCallArgs[0].name == "Next Pill Due")
	}

	public func testSet_whenPillExistsAndSettingById_updatesPill() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		let mockPills = setUpThreePills()
		let idToSet = mockPills[0].id

		pills.set(by: idToSet, with: attributes)
		let pill = pills[idToSet] as! MockPill

		XCTAssert(pill.setCallArgs.contains(where: { (_ a: PillAttributes) in a.name == "New Name" && a.time1 == testDate
			}))
	}

	public func testSet_whenPillExistsAndSettingById_savesChanges() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		let mockPills = setUpThreePills()
		let idToSet = mockPills[0].id

		pills.set(by: idToSet, with: attributes)
		XCTAssert(util.didSave(with: [mockPills[0]]))
	}

	public func testSet_whenPillExistsAndSettingById_sharedNextPillDue() {
		var attributes = PillAttributes()
		let testDate = Date()
		attributes.name = "New Name"
		attributes.time1 = testDate
		let mockPills = setUpThreePills()
		let idToSet = mockPills[0].id

		pills.set(by: idToSet, with: attributes)
		XCTAssert(util.didSave(with: [mockPills[0]]))
	}

	public func testSwallow_whenGivenPillIdForNonCompletedPill_swallowPillForGivenId() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 0
		mockPills[1].timesaday = 10

		pills.swallow(mockPills[1].id, onSuccess: nil)
		XCTAssert(mockPills[1].swallowCallCount == 1)
	}

	public func testSwallow_whenGivenPillIdForCompletedPill_doesNotSwallowPillForGivenId() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 10
		mockPills[1].timesaday = 10
		mockPills[1].lastTaken = Date()

		pills.swallow(mockPills[1].id, onSuccess: nil)
		XCTAssert(mockPills[1].swallowCallCount == 0)
	}

	public func testSwallow_whenGivenIdForExistentNonCompletedPill_callsOnSuccess() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 0
		mockPills[1].timesaday = 10

		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(mockPills[1].id, onSuccess: comp)
		XCTAssertTrue(didCall)
	}

	public func testSwallow_whenGivenIdForNonExistentPill_doesNotCallOnSuccess() {
		setUpThreePills()
		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(UUID(), onSuccess: comp)
		XCTAssertFalse(didCall)
	}

	public func testSwallow_whenGivenIdForCompletedPill_doesNotCallOnSuccess() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 0
		mockPills[1].timesaday = 10

		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(UUID(), onSuccess: comp)
		XCTAssertFalse(didCall)
	}

	public func testSwallow_withNoArgsAndNextPillDueIsNonCompleted_swallowsNextPill() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 0
		mockPills[1].timesaday = 10

		pills.swallow(onSuccess: nil)
		XCTAssert(mockPills[1].swallowCallCount == 1)
	}

	public func testSwallow_withNoArgsAndNextPillDueIsCompleted_doesNotSwallowPill() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 10
		mockPills[1].timesaday = 10
		mockPills[1].lastTaken = Date()

		pills.swallow(onSuccess: nil)
		XCTAssert(mockPills[1].swallowCallCount == 0)
	}

	public func testSwallow_whenGivenNoArgsAndPillDueIsNonCompleted_callsOnSuccess() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		// Pill is not done unless timesTakenToday == timesaday
		mockPills[1].timesTakenToday = 0
		mockPills[1].timesaday = 10

		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(mockPills[1].id, onSuccess: comp)
		XCTAssertTrue(didCall)
	}

	public func testSwallow_whenGivenArgsForNonExistentPill_doesNotCallOnSuccess() {
		setUpThreePills()
		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(UUID(), onSuccess: comp)
		XCTAssertFalse(didCall)
	}

	public func testSwallow_whenLastTakenIsNil_swallowsPill() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		mockPills[1].timesTakenToday = 10
		mockPills[1].timesaday = 10
		mockPills[1].lastTaken = nil // Key to test

		pills.swallow(mockPills[1].id, onSuccess: nil)
		XCTAssert(mockPills[1].swallowCallCount == 1)
	}

	public func testSwallow_whenLastTakenIsNil_callsOnSuccess() {
		let mockPills = setUpThreePillsWithMiddleOneNextDue()

		mockPills[1].timesTakenToday = 10
		mockPills[1].timesaday = 10
		mockPills[1].lastTaken = nil // Key to test

		var didCall = false
		let comp = { () in didCall = true }
		pills.swallow(mockPills[1].id, onSuccess: comp)
		XCTAssertTrue(didCall)
	}
}
