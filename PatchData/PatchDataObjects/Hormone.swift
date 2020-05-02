//
//  Hormone.swift
//  PatchData
//
//  Created by Juliya Smith on 8/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Hormone: Hormonal {

	private var hormoneData: HormoneStruct

	public var deliveryMethod: DeliveryMethod
	public var expirationInterval: ExpirationIntervalUD
	public var notificationsMinutesBefore: NotificationsMinutesBeforeUD

	public init(hormoneData: HormoneStruct, scheduleProperties: HormoneScheduleProperties) {
		self.hormoneData = hormoneData
		self.deliveryMethod = scheduleProperties.deliveryMethod
		self.expirationInterval = scheduleProperties.expirationInterval
		self.notificationsMinutesBefore = scheduleProperties.notificationsMinutesBefore
	}

	public var id: UUID {
		get { hormoneData.id }
		set { hormoneData.id = newValue }
	}

	public var siteId: UUID? {
		get { hormoneData.siteRelationshipId ?? nil }
		set {
			hormoneData.siteRelationshipId = newValue

			// Only clear back up if not explicitly setting to nil
			if let _ = newValue {
				hormoneData.siteNameBackUp = nil
			}
		}
	}

	public var siteName: SiteName? {
		get { hormoneData.siteName }
		set { hormoneData.siteName = newValue }
	}

	public var date: Date {
		get { (hormoneData.date as Date?) ?? DateFactory.createDefaultDate() }
		set { hormoneData.date = newValue }
	}

	public var expiration: Date? {
		if let date = date as Date?, !date.isDefault() {
			let hoursUntilExpires = expirationInterval.hours
			return DateFactory.createDate(byAddingHours: hoursUntilExpires, to: date)
		}
		return nil
	}

	public var expirationString: String {
		guard let expDate = expiration else {
			return PlaceholderStrings.DotDotDot
		}
		return PDDateFormatter.formatDate(expDate)
	}

	public var isExpired: Bool {
		guard let expDate = expiration else {
			return false
		}
		return expDate < Date()
	}

	public var isPastNotificationTime: Bool {
		if let expirationDate = expiration,
			let notificationTime = DateFactory.createDate(
				byAddingMinutes: -notificationsMinutesBefore.value, to: expirationDate
			) {

			return notificationTime < Date()
		}
		return false
	}

	public var expiresOvernight: Bool {
		guard let exp = expiration, !isExpired else {
			return false
		}
		return exp.isOvernight()
	}

	public var siteNameBackUp: String? {
		// Ignore backup name if there is a site relationship.
		get { siteId == nil ? hormoneData.siteNameBackUp : nil }
		set { hormoneData.siteNameBackUp = newValue }
	}

	public var isEmpty: Bool {
		!hasDate && !hasSite
	}

	public var hasSite: Bool {
		siteId != nil || siteNameBackUp != nil
	}

	public var hasDate: Bool {
		!date.isDefault()
	}

	public func stamp() {
		hormoneData.date = Date()
	}

	public func reset() {
		hormoneData.date = nil
		hormoneData.siteRelationshipId = nil
		hormoneData.siteNameBackUp = nil
	}
}
