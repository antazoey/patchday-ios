//
//  HormoneScheduleProperties.swift
//  PDKit
//
//  Created by Juliya Smith on 1/13/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public struct HormoneScheduleProperties {
    public var expirationInterval: ExpirationIntervalUD
    public var deliveryMethod: DeliveryMethod
    public var notificationMinutesBefore: NotificationsMinutesBeforeUD
    
    public init(_ defaults: UserDefaultsReading) {
        self.expirationInterval = defaults.expirationInterval
        self.deliveryMethod = defaults.deliveryMethod.value
        self.notificationMinutesBefore = defaults.notificationsMinutesBefore
    }
}
