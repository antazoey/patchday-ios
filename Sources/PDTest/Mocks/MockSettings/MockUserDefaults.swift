//
//  MockUserDefaults.swift
//  PDTest
//
//  Created by Juliya Smith on 5/9/20.

import Foundation
import PDKit

public class MockUserDefaults: UserDefaultsProtocol {

    public init() {}

    public var setCallArgs: [(Any?, String)] = []
    public func set(_ value: Any?, for key: String) {
        setCallArgs.append((value, key))
    }

    public var mockObjectMap: [String: Any?] = [
        PDSetting.SiteIndex.rawValue: DefaultSettings.SITE_INDEX_RAW_VALUE,
        PDSetting.Quantity.rawValue: DefaultSettings.QUANTITY_RAW_VALUE,
        PDSetting.DeliveryMethod.rawValue: DefaultSettings.DELIVERY_METHOD_RAW_VALUE,
        PDSetting.ExpirationInterval.rawValue: DefaultSettings.EXPIRATION_INTERVAL_RAW_VALUE,
        PDSetting.Notifications.rawValue: DefaultSettings.NOTIFICATIONS_RAW_VALUE,
        PDSetting.NotificationsMinutesBefore.rawValue:
            DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE,
        PDSetting.MentionedDisclaimer.rawValue: DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE
    ]
    public func object(for key: String) -> Any? {
        mockObjectMap[key] ?? nil  // Coerces from double-nil
    }
}
