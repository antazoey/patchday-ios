//
//  MockSettings.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.

import Foundation
import PDKit

public class MockSettings: SettingsManaging {

    public var deliveryMethod = DeliveryMethodUD()
    public var expirationInterval = ExpirationIntervalUD()
    public var quantity = QuantityUD()
    public var notifications = NotificationsUD()
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer = MentionedDisclaimerUD()
    public var siteIndex = SiteIndexUD()
    public var pillsEnabled = PillsEnabledUD()

    public init() {}

    public var setDeliveryMethodCallArgs: [DeliveryMethod] = []
    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        setDeliveryMethodCallArgs.append(newMethod)
    }

    public var setQuantityCallArgs: [Int] = []
    public func setQuantity(to newQuantity: Int) {
        setQuantityCallArgs.append(newQuantity)
    }

    public var setExpirationIntervalCallArgs: [String] = []
    public func setExpirationInterval(to newInterval: String) {
        setExpirationIntervalCallArgs.append(newInterval)
    }

    public var setNotificationsCallArgs: [Bool] = []
    public func setNotifications(to newValue: Bool) {
        setNotificationsCallArgs.append(newValue)
    }

    public var setNotificationsMinutesBeforeCallArgs: [Int] = []
    public func setNotificationsMinutesBefore(to newMinutes: Int) {
        setNotificationsMinutesBeforeCallArgs.append(newMinutes)
    }

    public var setMentionedDisclaimerCallArgs: [Bool] = []
    public func setMentionedDisclaimer(to newValue: Bool) {
        setMentionedDisclaimerCallArgs.append(newValue)
    }

    public var setSiteIndexCallArgs: [Index] = []
    @discardableResult
    public func setSiteIndex(to newIndex: Index) -> Index {
        setSiteIndexCallArgs.append(newIndex)
        return newIndex
    }

    public var setPillsEnabledCallArgs: [Bool] = []
    public func setPillsEnabled(to newValue: Bool) {
        setPillsEnabledCallArgs.append(newValue)
    }

    public var resetCallArgs: [Int] = []
    public func reset(defaultSiteCount: Int) {
        resetCallArgs.append(defaultSiteCount)
    }
}
