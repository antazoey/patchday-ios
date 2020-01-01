//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import PDKit


struct ExpiredHormoneNotificationCreationParams {
    var hormone: Hormonal
    var expiringSiteName: String
    var deliveryMethod: DeliveryMethod
    var expiration: ExpirationIntervalUD
    var notificationMinutesBefore: Double
    var totalHormonesExpired: Int
}

struct ExpiredHormoneOvernightNotificationCreationParams {
    var triggerDate: Date
    var deliveryMethod: DeliveryMethod
    var totalHormonesExpired: Int
}