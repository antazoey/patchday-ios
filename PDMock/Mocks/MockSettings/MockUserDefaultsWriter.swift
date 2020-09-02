//
// Created by Juliya Smith on 1/7/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockUserDefaultsWriter: PDMocking, UserDefaultsWriting {

	public var deliveryMethod = DeliveryMethodUD(DefaultSettings.DeliveryMethodRawValue)
	public var expirationInterval = ExpirationIntervalUD(DefaultSettings.ExpirationIntervalRawValue)
	public var quantity = QuantityUD(DefaultSettings.QuantityRawValue)
	public var notifications = NotificationsUD(DefaultSettings.NotificationsRawValue)
	public var notificationsMinutesBefore = NotificationsMinutesBeforeUD(DefaultSettings.NotificationsMinutesBeforeRawValue)
	public var mentionedDisclaimer = MentionedDisclaimerUD(DefaultSettings.MentionedDisclaimerRawValue)
	public var siteIndex = SiteIndexUD(DefaultSettings.SiteIndexRawValue)

	public init() { }

	public func resetMock() {
		replaceStoredDeliveryMethodCallArgs = []
		replaceStoredExpirationIntervalCallArgs = []
		replaceStoredQuantityCallArgs = []
		resetCallArgs = []
		replaceSiteIndexMockReturnValue = 0
	}

	public var replaceStoredDeliveryMethodCallArgs: [DeliveryMethod] = []
	public var replaceStoredExpirationIntervalCallArgs: [ExpirationInterval] = []
	public var replaceStoredQuantityCallArgs: [Quantity] = []
	public var resetCallArgs: [Int] = []
	public var replaceSiteIndexMockReturnValue = 0

	public func reset(defaultSiteCount: Int) {
		resetCallArgs.append(defaultSiteCount)
	}

	public func replaceStoredDeliveryMethod(to newMethod: DeliveryMethod) {
		replaceStoredDeliveryMethodCallArgs.append(newMethod)
	}

	public func replaceStoredExpirationInterval(to newExpirationInterval: ExpirationInterval) {
		replaceStoredExpirationIntervalCallArgs.append(newExpirationInterval)
	}

	public func replaceStoredQuantity(to newQuantity: Int) {
		self.quantity = QuantityUD(newQuantity)
	}

	public func replaceStoredNotifications(to newNotitifications: Bool) {
		self.notifications = NotificationsUD(newNotitifications)
	}

	public func replaceStoredNotificationsMinutesBefore(to newNotificationsMinutesBefore: Int) {
		self.notificationsMinutesBefore = NotificationsMinutesBeforeUD(newNotificationsMinutesBefore)
	}

	public func replaceStoredMentionedDisclaimer(to newMentionedDisclaimer: Bool) {
		self.mentionedDisclaimer = MentionedDisclaimerUD(newMentionedDisclaimer)
	}

	public func replaceStoredSiteIndex(to i: Index) -> Index {
		self.siteIndex = SiteIndexUD(i)
		return i
	}

	public var incrementStoredSiteIndexCallArgs: [Int?] = []
	public func incrementStoredSiteIndex(from start: Int?) -> Index {
		incrementStoredSiteIndexCallArgs.append(start)
		self.siteIndex = SiteIndexUD(self.siteIndex.rawValue + 1)
		return self.siteIndex.rawValue + 1
	}
}
