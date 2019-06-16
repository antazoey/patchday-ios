//
//  PDNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications

public class PDNotification {
    
    public var content: UNMutableNotificationContent
    
    init(title: String, body: String?, badge: Int) {
        content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = title
        content.body = body ?? ""
        content.badge = badge as NSNumber
    }
    
    public func send(when interval: Double, requestId: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let e = error {
                let msg = "Unable to Add Notification Request "
                let emsg = "(\(String(describing: e)), "
                let desc = "\(String(describing: e.localizedDescription)))"
                print(msg + emsg + desc)
            }
        }
    }
}
