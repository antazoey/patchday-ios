//
//  NotificationFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

// This class mainly exists to increase testability in other notifications classes
class NotificationFactory: NotificationProducing {

    typealias ExpParams = ExpiredHormoneNotificationCreationParams
    typealias ExpOvernightParams = ExpiredHormoneOvernightNotificationCreationParams
    
    func createExpiredHormoneNotification(_ params: ExpParams) -> ExpiredHormoneNotifying {
        ExpiredHormoneNotification(params)
    }
    
    func createDuePillNotification(_ pill: PillStruct, totalDue: Int) -> DuePillNotifying {
        DuePillNotification(for: pill, totalDue: totalDue)
    }
    
    func createOvernightExpiredHormoneNotification(_ params: ExpOvernightParams) -> ExpiredHormoneOvernightNotifying {
        ExpiredHormoneOvernightNotification(params)
    }
}
