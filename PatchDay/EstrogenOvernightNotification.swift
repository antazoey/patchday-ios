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

public class EstrogenOvernightNotification : PDNotification, PDNotifying {
    
    private let dateBeforeOvernightExpiration: Date
    private let deliveryMethod: DeliveryMethod
    
    public var title: String
    public var body: String?
    
    init(triggerDate: Date, deliveryMethod: DeliveryMethod, totalDue: Int) {
        self.dateBeforeOvernightExpiration = triggerDate
        self.deliveryMethod = deliveryMethod
        
        switch self.deliveryMethod {
        case .Patches:
            self.title = PDNotificationStrings.overnightPatch
        case .Injections:
            self.title = PDNotificationStrings.overnightInjection
        }
        
        super.init(title: title, body: body, badge: totalDue)
    }
    
    public func send() {
        let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
        if interval > 0 {
            super.send(when: interval, requestId: "overnight")
        }
    }
}
