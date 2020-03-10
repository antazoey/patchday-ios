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
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD
    
    public init(_ settings: UserDefaultsReading) {
        self.expirationInterval = settings.expirationInterval
        self.deliveryMethod = settings.deliveryMethod.value
        self.notificationsMinutesBefore = settings.notificationsMinutesBefore
    }
    
    public init(
        _ expirationInterval: ExpirationIntervalUD,
        _ deliveryMethod: DeliveryMethod,
        _ notificationsMinutesBefore: NotificationsMinutesBeforeUD) {

        self.expirationInterval = expirationInterval
        self.deliveryMethod = deliveryMethod
        self.notificationsMinutesBefore = notificationsMinutesBefore
    }
}
