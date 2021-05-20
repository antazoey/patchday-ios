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
        PDSetting.SiteIndex.rawValue: DefaultSettings.SiteIndexRawValue,
        PDSetting.Quantity.rawValue: DefaultSettings.QuantityRawValue,
        PDSetting.DeliveryMethod.rawValue: DefaultSettings.DeliveryMethodRawValue,
        PDSetting.ExpirationInterval.rawValue: DefaultSettings.ExpirationIntervalRawValue,
        PDSetting.Notifications.rawValue: DefaultSettings.NotificationsRawValue,
        PDSetting.NotificationsMinutesBefore.rawValue:
            DefaultSettings.NotificationsMinutesBeforeRawValue,
        PDSetting.MentionedDisclaimer.rawValue: DefaultSettings.MentionedDisclaimerRawValue
    ]
    public func object(for key: String) -> Any? {
        mockObjectMap[key] ?? nil  // Coerces from double-nil
    }
}
