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

	public init(hormoneData: HormoneStruct, settings: UserDefaultsReading) {
		self.hormoneData = hormoneData
		self.deliveryMethod = settings.deliveryMethod.value
		self.expirationInterval = settings.expirationInterval
		self.notificationsMinutesBefore = settings.notificationsMinutesBefore
	}

	public func from(_ settings: UserDefaultsReading) -> Hormonal {
		self.deliveryMethod = settings.deliveryMethod.value
		self.expirationInterval = settings.expirationInterval
		self.notificationsMinutesBefore = settings.notificationsMinutesBefore
		return self
	}

	public var id: UUID {
		get { hormoneData.id }
		set { hormoneData.id = newValue }
	}

	public var siteId: UUID? {
		get { hormoneData.siteRelationshipId ?? nil }
		set {
			hormoneData.siteRelationshipId = newValue
			hormoneData.siteImageId = nil
			// Only clear back up if not explicitly setting to nil
			if let _ = newValue {
				hormoneData.siteNameBackUp = nil
			}
		}
	}

	public var siteName: SiteName {
		get {
			let backup = hormoneData.siteNameBackUp == "" ?
				SiteStrings.NewSite : hormoneData.siteNameBackUp ?? SiteStrings.NewSite
			guard let name = hormoneData.siteName, name != "", name != SiteStrings.NewSite else {
				return backup
			}
			hormoneData.siteImageId = nil
			return name
		}
		set { hormoneData.siteName = newValue }
	}

	public var siteImageId: SiteName {
		get {
			guard let id = hormoneData.siteImageId else {
				return siteName
			}
			return id == "" || id == SiteStrings.NewSite ? siteName : id
		}
		set { hormoneData.siteImageId = newValue }
	}

	public var date: Date {
		get { (hormoneData.date as Date?) ?? DateFactory.createDefaultDate() }
		set { hormoneData.date = newValue }
	}

	public var expiration: Date? {
		if let date = date as Date?, !date.isDefault() {
			return createExpirationDate(from: date)
		}
		return nil
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
		// Ignore backup name if there _is_ a site relationship.
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

	public func createExpirationDate(from startDate: Date) -> Date? {
		DateFactory.createExpirationDate(expirationInterval: expirationInterval, to: date)
	}
}
