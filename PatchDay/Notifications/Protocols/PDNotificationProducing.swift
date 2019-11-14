//
//  PDNotificationProducing.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

protocol PDNotificationProducing {
    
    func createExpiredHormoneNotification(
        _ hormone: Hormonal,
        deliveryMethod: DeliveryMethod,
        expiration: ExpirationIntervalUD,
        notifyMinutesBefore: Double,
        totalDue: Int
    ) -> ExpiredHormoneNotifying
    
    func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> DuePillNotifying
    
    func createOvernightExpiredHormoneNotification(
        triggerDate: Date, deliveryMethod: DeliveryMethod, totalDue: Int
    ) -> ExpiredHormoneOvernightNotifying
}
