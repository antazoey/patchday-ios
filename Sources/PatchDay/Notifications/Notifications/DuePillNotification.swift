//
//  DuePillNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class DuePillNotification: Notification, PDNotificationProtocol {

    private let pill: Swallowable

    public static var actionId = { "takeActionId" }()
    public static var categoryId = { "pillCategoryId" }()

    init(
        for pill: Swallowable,
        currentBadgeValue: Int,
        requestHandler: ((_ interval: Double, _ id: String)-> Void)?=nil
    ) {
        self.pill = pill
        let title = "\(NotificationStrings.takePill)\(pill.name)"
        super.init(
            title: title,
            body: nil,
            currentBadgeValue: currentBadgeValue,
            requestHandler: requestHandler
        )
    }

    public func request() {
        super.content.categoryIdentifier = DuePillNotification.categoryId
        guard let dueDate = pill.due else { return }
        let interval = dueDate.timeIntervalSince(Date())
        guard interval > 0 else { return }
        let dueDateString = PDDateFormatter.formatDate(dueDate)
        let logMessage =  "Pill notification in \(interval), due: \(dueDateString)"
        PDLog<DuePillNotification>().info(logMessage)
        super.request(when: interval, requestId: pill.id.uuidString)
    }
}
