//
//  UserDefaultsWriterTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 5/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData

class UserDefaultsWriterTests: XCTestCase {

	private func createMockSiteStore(count: Int, freeHormoneIndex: Index) -> MockSiteStore {
		let store = MockSiteStore()
		store.siteCount = count
		var sites: [Bodily] = []
		if count > 0 {
			for i in 0..<count {
				let site = MockSite()
				site.order = i
				sites.append(site)
				// Sets all but one of the sites to have hormones
				if site.order != freeHormoneIndex {
					site.hormoneCount = 1
				}
			}
		}
		store.getStoredCollectionReturnValues.append(sites)
		return store
	}
	private var handler = UserDefaultsWriteHandler(
		baseDefaults: MockUserDefaultsInterface(), dataSharer: MockUserDefaultsInterface()
	)

	func testReset() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
		)
		writer.reset()
		XCTAssertEqual(DefaultSettings.DeliveryMethodRawValue, writer.deliveryMethod.rawValue)
		XCTAssertEqual(DefaultSettings.QuantityRawValue, writer.quantity.rawValue)
		XCTAssertEqual(
			DefaultSettings.ExpirationIntervalRawValue, writer.expirationInterval.rawValue
		)
		XCTAssertEqual(
			DefaultSettings.MentionedDisclaimerRawValue, writer.mentionedDisclaimer.rawValue
		)
		XCTAssertEqual(
			DefaultSettings.NotificationsMinutesBeforeRawValue,
			writer.notificationsMinutesBefore.rawValue
		)
		XCTAssertEqual(DefaultSettings.NotificationsRawValue, writer.notifications.rawValue)
		XCTAssertEqual(DefaultSettings.SiteIndexRawValue, writer.siteIndex.rawValue)
	}

	func testSetDeliveryMethod_whenSettingsToPatches_setsQuantityToDefault() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
		)
		writer.replaceStoredDeliveryMethod(to: .Patches)
		XCTAssertEqual(3, writer.quantity.rawValue)
	}

	func testIncrementStoredSiteIndex_whenRoomToIncrementAndNextIsFree_incrementsNormally() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
		)
		writer.siteIndex = SiteIndexUD(1)
		let expected = 2
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementStoredSiteIndex_whenSiteIndexEqualsCount_setsToFirstFreeHormoneIndex() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 1)
		)
		writer.siteIndex = SiteIndexUD(4)
		let expected = 1
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementStoredSiteIndex_whenSiteIndexGreaterThanCount_setsToFirstFreeHormoneIndex() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
		)
		writer.siteIndex = SiteIndexUD(7)
		let expected = 2
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenSiteCountZero_setsToFirstFreeHormoneIndex() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 0, freeHormoneIndex: 0)
		)
		writer.siteIndex = SiteIndexUD(7)
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenSiteIndexAtLastIndex_setsToFreeHormoneIndex() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
		)
		writer.siteIndex = SiteIndexUD(4)
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenSiteIndexNegative_setsToFirstFreeHormoneIndex() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
		)
		writer.siteIndex = SiteIndexUD(-4)
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenSiteIndexZeroAndNextIsFree_setsToOne() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 1)
		)
		writer.siteIndex = SiteIndexUD(0)
		let expected = 1
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenGivenStartAndIndexAfterIsFree_usesGivenStart() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
		)
		writer.siteIndex = SiteIndexUD(0)
		let expected = 3
		let r = writer.incrementStoredSiteIndex(from: 2)
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}

	func testIncrementSiteIndex_whenNextSiteIndexIsOccupied_returnsFirstIndexThatIsNotOccupied() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
		)
		writer.siteIndex = SiteIndexUD(0) // Thinks it should be 0+1 but actually should be 3
		let actual = writer.incrementStoredSiteIndex()
		XCTAssertEqual(3, actual)
	}

	func testIncrementSiteIndex_whenFromSiteIndexIsOccupied_returnsFirstIndexThatIsNotOccupied() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
		)
		writer.siteIndex = SiteIndexUD(0)
		let actual = writer.incrementStoredSiteIndex(from: 1)
		XCTAssertEqual(3, actual)
	}

	func testIncrementSiteIndex_whenCountIsMax_returnsSuggested() {
		let writer = UserDefaultsWriter(
			handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
		)
		writer.quantity = QuantityUD(SupportedHormoneUpperQuantityLimit)
		writer.siteIndex = SiteIndexUD(0)
		let expected = 1
		let actual = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, actual)
	}
}
