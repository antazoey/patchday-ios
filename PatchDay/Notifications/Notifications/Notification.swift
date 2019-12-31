//
//  Notification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit


public class Notification {
    
    public var content: UNMutableNotificationContent
    private let log = PDLog<Notifications>()
    
    init(title: String, body: String?, badge: Int) {
        content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = title
        content.body = body ?? ""
        content.badge = badge as NSNumber
    }
    
    public func request(when interval: Double, requestId: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let e = error {
                self.log.error("Unable to add notification request", e)
            }
        }
    }
}
