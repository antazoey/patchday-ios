//
//  PDNotificationScheduling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/25/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

protocol PDNotificationScheduling {
    func cancelHormoneNotification(at index: Index)
    func cancelHormoneNotifications(from begin: Index, to end: Index)
    func cancelAllHormoneExpiredNotifications()
    func requestHormoneExpiredNotification(for hormone: Hormonal)
    func resendHormoneExpiredNotifications(from begin: Index, to end: Index)
    func resendAllHormoneExpiredNotifications()
    func requestOvernightNotification(_ hormone: Hormonal, expDate: Date)
    func requestPillNotification(forPillAt index: Index)
    func cancelPillNotification(_ pill: Swallowable)
    func requestPillNotification(_ pill: Swallowable)
}
