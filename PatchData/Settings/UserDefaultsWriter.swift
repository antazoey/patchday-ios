//
//  UserDefaultsWriter.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class UserDefaultsWriter: UserDefaultsWriting {

	// Dependencies
	private let handler: UserDefaultsWriteHandler

	// Defaults
	public var deliveryMethod: DeliveryMethodUD
	public var expirationInterval: ExpirationIntervalUD
	public var quantity: QuantityUD
	public var notifications: NotificationsUD
	public var notificationsMinutesBefore: NotificationsMinutesBeforeUD
	public var mentionedDisclaimer: MentionedDisclaimerUD
	public var siteIndex: SiteIndexUD

	private var sites: SiteStoring

	init(handler: UserDefaultsWriteHandler, siteStore: SiteStoring) {
		self.handler = handler
		self.sites = siteStore
		typealias D = DefaultSettings

		let deliveryMethod = handler.load(setting: .DeliveryMethod, defaultValue: D.DeliveryMethodRawValue)
		let expirationInterval = handler.load(
			setting: .ExpirationInterval, defaultValue: D.ExpirationIntervalRawValue
		)
		let quantity = handler.load(setting: .Quantity, defaultValue: D.QuantityRawValue)
		let notifications = handler.load(setting: .Notifications, defaultValue: D.NotificationsRawValue)
		let notificationsMinutesBefore = handler.load(
			setting: .NotificationsMinutesBefore, defaultValue: D.NotificationsMinutesBeforeRawValue
		)
		let mentionedDisclaimer = handler.load(
			setting: .MentionedDisclaimer, defaultValue: D.MentionedDisclaimerRawValue
		)
		let siteIndex = handler.load(setting: .SiteIndex, defaultValue: D.SiteIndexRawValue)

		self.deliveryMethod = DeliveryMethodUD(deliveryMethod)
		self.expirationInterval = ExpirationIntervalUD(expirationInterval)
		self.quantity = QuantityUD(quantity)
		self.notifications = NotificationsUD(notifications)
		self.notificationsMinutesBefore = NotificationsMinutesBeforeUD(notificationsMinutesBefore)
		self.mentionedDisclaimer = MentionedDisclaimerUD(mentionedDisclaimer)
		self.siteIndex = SiteIndexUD(siteIndex)
	}

	public func reset(defaultSiteCount: Int = 4) {
		replaceStoredDeliveryMethod(to: DefaultSettings.DeliveryMethodValue)
		replaceStoredExpirationInterval(to: DefaultSettings.ExpirationIntervalValue)
		replaceStoredQuantity(to: DefaultSettings.QuantityRawValue)
		replaceStoredNotifications(to: DefaultSettings.NotificationsRawValue)
		replaceStoredNotificationsMinutesBefore(to: DefaultSettings.NotificationsMinutesBeforeRawValue)
		replaceStoredMentionedDisclaimer(to: DefaultSettings.MentionedDisclaimerRawValue)
		replaceStoredSiteIndex(to: DefaultSettings.SiteIndexRawValue)

	}

	public func replaceStoredDeliveryMethod(to newValue: DeliveryMethod) {
		let rawValue = DeliveryMethodUD.getRawValue(for: newValue)
		//let newQuantity = DefaultQuantities.Hormone[newValue]
		handler.replace(&deliveryMethod, to: rawValue)
		//handler.replace(&quantity, to: newQuantity)
	}

	@objc public func replaceStoredQuantity(to newValue: Int) {
		handler.replace(&quantity, to: newValue)
	}

	public func replaceStoredExpirationInterval(to newValue: ExpirationInterval) {
		let rawValue = ExpirationIntervalUD.getRawValue(for: newValue)
		handler.replace(&expirationInterval, to: rawValue)
	}

	public func replaceStoredNotifications(to newValue: Bool) {
		handler.replace(&notifications, to: newValue)
	}

	public func replaceStoredNotificationsMinutesBefore(to newValue: Int) {
		handler.replace(&notificationsMinutesBefore, to: newValue)
	}

	public func replaceStoredMentionedDisclaimer(to newValue: Bool) {
		handler.replace(&mentionedDisclaimer, to: newValue)
	}

	@discardableResult
	public func replaceStoredSiteIndex(to newValue: Index) -> Index {
		let storedSites = sites.getStoredSites()
		if storedSites.count == 0 || newValue >= storedSites.count || newValue < 0 {
			handler.replace(&siteIndex, to: 0)
			return 0
		}
		var newIndex = newValue
		let site = storedSites[newIndex]
		if quantity.rawValue != SupportedHormoneUpperQuantityLimit && site.hormoneCount > 0 {
			for site in storedSites {
				if site.hormoneCount == 0 {
					newIndex = site.order
					break
				}
			}
		}
		PDLog<UserDefaultsWriter>().info("Settings new site index to \(newIndex)")
		handler.replace(&siteIndex, to: newIndex)
		return newIndex
	}

	@discardableResult
	public func incrementStoredSiteIndex(from start: Int?=nil) -> Index {
		let currentIndex = start ?? siteIndex.value
		let siteCount = sites.siteCount

		if siteCount == 0 {
			handler.replace(&siteIndex, to: 0)
			return 0
		}

		if currentIndex < 0 || currentIndex >= siteCount {
			return replaceStoredSiteIndex(to: 0)
		}
		let incrementedIndex = (currentIndex + 1) % sites.siteCount
		return replaceStoredSiteIndex(to: incrementedIndex)
	}
}
