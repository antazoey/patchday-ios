//
//  PDNotificationFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PDNotificationFactory: PDNotificationProducing {
    
    func createExpiredHormoneNotification(
        _ hormone: Hormonal,
        deliveryMethod: DeliveryMethod,
        expirationInterval: ExpirationIntervalUD,
        notifyMinutesBefore: Double,
        totalDue: Int
    ) -> ExpiredHormoneNotifying {

        return ExpiredHormoneNotification(
            for: hormone,
            deliveryMethod: deliveryMethod,
            expirationInterval: expirationInterval,
            notifyMinutesBefore: notifyMinutesBefore,
            totalDue: totalDue
        )
    }
    
    func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> DuePillNotifying {
        return DuePillNotification(for: pill, totalDue: totalDue)
    }
    
    func createOvernightExpiredHormoneNotification(
        triggerDate: Date, deliveryMethod: DeliveryMethod, totalDue: Int
    ) -> ExpiredHormoneOvernightNotifying {

        return ExpiredHormoneOvernightNotification(
            triggerDate: triggerDate,
            deliveryMethod: deliveryMethod,
            totalDue: totalDue
        )
    }
}
