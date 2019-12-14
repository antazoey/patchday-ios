//
//  EstrogenOvernightNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class ExpiredHormoneOvernightNotification: Notification, ExpiredHormoneOvernightNotifying {
    
    private let dateBeforeOvernightExpiration: Date
    private let deliveryMethod: DeliveryMethod
    
    init(_ params: ExpiredHormoneOvernightNotificationCreationParams) {
        self.dateBeforeOvernightExpiration = params.triggerDate
        self.deliveryMethod = params.deliveryMethod
        let title = NotificationStrings.getOvernightString(for: deliveryMethod)
        super.init(title: title, body: nil, badge: params.totalHormonesExpired)
    }
    
    public func request() {
        let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
        if interval > 0 {
            super.request(when: interval, requestId: "overnight")
        }
    }
}
