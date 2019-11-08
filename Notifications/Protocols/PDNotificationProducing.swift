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
        expirationInterval: ExpirationIntervalUD,
        notifyMinutesBefore: Double,
        totalDue: Int
    ) -> PDNotifying
}
