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
    
    init(triggerDate: Date, deliveryMethod: DeliveryMethod, totalDue: Int) {
        self.dateBeforeOvernightExpiration = triggerDate
        self.deliveryMethod = deliveryMethod
        let title = NotificationStrings.getOvernightString(for: deliveryMethod)
        super.init(title: title, body: nil, badge: totalDue)
    }
    
    public func request() {
        let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
        if interval > 0 {
            super.request(when: interval, requestId: "overnight")
        }
    }
}
