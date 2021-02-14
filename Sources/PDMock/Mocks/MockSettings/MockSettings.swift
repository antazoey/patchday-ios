//
//  MockSettings.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.

import Foundation
import PDKit

public class MockSettings: PDSettingsManaging {

    public var deliveryMethod: DeliveryMethodUD = DeliveryMethodUD()
    public var expirationInterval: ExpirationIntervalUD = ExpirationIntervalUD()
    public var quantity: QuantityUD = QuantityUD()
    public var notifications: NotificationsUD = NotificationsUD()
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer: MentionedDisclaimerUD = MentionedDisclaimerUD()
    public var siteIndex: SiteIndexUD = SiteIndexUD()

    public var setDeliveryMethodCallArgs: [DeliveryMethod] = []
    public var setQuantityCallArgs: [Int] = []
    public var setExpirationIntervalCallArgs: [String] = []
    public var setNotificationsCallArgs: [Bool] = []
    public var setNotificationsMinutesBeforeCallArgs: [Int] = []
    public var setMentionedDisclaimerCallArgs: [Bool] = []
    public var setSiteIndexCallArgs: [Index] = []
    public var resetCallArgs: [Int] = []

    public init() {

    }

    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        setDeliveryMethodCallArgs.append(newMethod)
    }

    public func setQuantity(to newQuantity: Int) {
        setQuantityCallArgs.append(newQuantity)
    }

    public func setExpirationInterval(to newInterval: String) {
        setExpirationIntervalCallArgs.append(newInterval)
    }

    public func setNotifications(to newValue: Bool) {
        setNotificationsCallArgs.append(newValue)
    }

    public func setNotificationsMinutesBefore(to newMinutes: Int) {
        setNotificationsMinutesBeforeCallArgs.append(newMinutes)
    }

    public func setMentionedDisclaimer(to newValue: Bool) {
        setMentionedDisclaimerCallArgs.append(newValue)
    }

    @discardableResult
    public func setSiteIndex(to newIndex: Index) -> Index {
        setSiteIndexCallArgs.append(newIndex)
        return newIndex
    }

    public func reset(defaultSiteCount: Int) {
        resetCallArgs.append(defaultSiteCount)
    }
}
