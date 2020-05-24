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
	private lazy var log = PDLog<Notifications>()

    public var title: String
    public var body: String?
	private let badge: PDBadgeDelegate
    private var requestHandler: ((_ interval: Double, _ id: String) -> Void)?

    init(
        title: String,
        body: String?,
        categoryId: String?=nil,
		badge: PDBadgeDelegate,
        requestHandler: ((_ interval: Double, _ id: String)-> Void)?=nil
    ) {
        self.title = title
        self.body = body
		self.badge = badge
        self.requestHandler = requestHandler
		let newBadge = badge.value + 1
		content = UNMutableNotificationContent()
		content.sound = UNNotificationSound.default
		content.title = title
		content.body = body ?? ""
		content.badge = NSNumber(value: newBadge >= 0 ? newBadge : 0)
        if let catId = categoryId {
            content.categoryIdentifier = catId
        }
	}

    public func request(when interval: Double, requestId: String) {
        if let handler = requestHandler {
            handler(interval, requestId)
        } else {
            _request(interval, requestId)
        }
    }

	private func _request(_ interval: Double, _ requestId: String) {
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
		let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request) { (error: Error?) in
			if let e = error {
				self.log.error("Unable to add notification request", e)
			}
		}
	}
}
