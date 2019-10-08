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
    func cancelHormoneNotifications(from start: Index, to end: Index)
    func cancelHormones()
    func cancel(_ pill: Swallowable)
    func requestHormoneExpiredNotification(for hormone: Hormonal)
    func requestOvernightNotification(_ hormone: Hormonal, expDate: Date)
    func requestPillNotification(forPillAt index: Index)
    func requestPillNotification(_ pill: Swallowable)
    func resendEstrogenNotifications(begin: Index, end: Index)
}
