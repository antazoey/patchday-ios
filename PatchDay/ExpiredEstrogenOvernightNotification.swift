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

public class ExpiredEstrogenOvernightNotification : PDNotification, PDNotifying {
    
    private let dateBeforeOvernightExpiration: Date
    private let deliveryMethod: DeliveryMethod
    
    init(triggerDate: Date, deliveryMethod: DeliveryMethod, totalDue: Int) {
        self.dateBeforeOvernightExpiration = triggerDate
        self.deliveryMethod = deliveryMethod
        var t: String
        
        switch self.deliveryMethod {
        case .Patches:
            t = PDNotificationStrings.overnightPatch
        case .Injections:
            t = PDNotificationStrings.overnightInjection
        }
        
        super.init(title: t, body: nil, badge: totalDue)
    }
    
    public func request() {
        let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
        if interval > 0 {
            super.request(when: interval, requestId: "overnight")
        }
    }
}
