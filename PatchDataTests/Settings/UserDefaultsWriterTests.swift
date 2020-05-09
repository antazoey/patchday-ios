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
	
	private static var getSiteCountReturnValue = 0
	private var getSiteCount: () -> Int = { getSiteCountReturnValue }
	private var handler = UserDefaultsWriteHandler(baseDefaults: MockUserDefaultsInterface(), dataSharer: MockUserDefaultsInterface())
	
	func testReset() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		writer.reset()
		XCTAssertEqual(DefaultSettings.DeliveryMethodRawValue, writer.deliveryMethod.rawValue)
		XCTAssertEqual(DefaultSettings.QuantityRawValue, writer.quantity.rawValue)
		XCTAssertEqual(DefaultSettings.ExpirationIntervalRawValue, writer.expirationInterval.rawValue)
		XCTAssertEqual(DefaultSettings.MentionedDisclaimerRawValue, writer.mentionedDisclaimer.rawValue)
		XCTAssertEqual(DefaultSettings.NotificationsMinutesBeforeRawValue, writer.notificationsMinutesBefore.rawValue)
		XCTAssertEqual(DefaultSettings.NotificationsRawValue, writer.notifications.rawValue)
		XCTAssertEqual(DefaultSettings.SiteIndexRawValue, writer.siteIndex.rawValue)
	}
	
	func testSetDeliveryMethod_whenSettingsToPatches_setsQuantityToDefault() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		writer.replaceStoredDeliveryMethod(to: .Patches)
		XCTAssertEqual(3, writer.quantity.rawValue)
	}
	
	func testSetDeliveryMethod_whenSettingsToInjections_setsQuantityToDefault() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		writer.replaceStoredDeliveryMethod(to: .Injections)
		XCTAssertEqual(1, writer.quantity.rawValue)
	}
	
	func testSetDeliveryMethod_whenSettingsToGel_setsQuantityToDefault() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		writer.replaceStoredDeliveryMethod(to: .Gel)
		XCTAssertEqual(1, writer.quantity.rawValue)
	}
	
	func testIncrementStoredSiteIndex_whenRoomToIncrement_incrementsNormally() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 4
		writer.siteIndex = SiteIndexUD(1)
		
		let expected = 2
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementStoredSiteIndex_whenSiteIndexEqualsCount_setsToZero() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 4
		writer.siteIndex = SiteIndexUD(4)

		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementStoredSiteIndex_whenSiteIndexGreaterThanCount_setsToZero() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 4
		writer.siteIndex = SiteIndexUD(7)
		
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementSiteIndex_whenSiteCountZero_setsToZero() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 0
		writer.siteIndex = SiteIndexUD(7)
		
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementSiteIndex_whenSiteIndexAtLastIndex_setsToZero() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 5
		writer.siteIndex = SiteIndexUD(4)
		
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementSiteIndex_whenSiteIndexNegative_setsToZero() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 5
		writer.siteIndex = SiteIndexUD(-4)
		
		let expected = 0
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
	
	func testIncrementSiteIndex_whenSiteIndexZero_setsToOne() {
		let writer = UserDefaultsWriter(handler: handler, getSiteCount: getSiteCount)
		UserDefaultsWriterTests.getSiteCountReturnValue = 4
		writer.siteIndex = SiteIndexUD(0)
		
		let expected = 1
		let r = writer.incrementStoredSiteIndex()
		XCTAssertEqual(expected, r)
		XCTAssertEqual(expected, writer.siteIndex.rawValue)
	}
}
