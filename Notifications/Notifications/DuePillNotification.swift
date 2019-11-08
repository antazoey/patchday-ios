//
//  PillNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class DuePillNotification : PDNotification, PDNotifying {
    
    private let pill: Swallowable
    private let dueDate: Date
    
    public var title: String
    public var body: String?
    public static var actionId = { return "takeActionId" }()
    public static var categoryId = { return "pillCategoryId" }()
    
    init(for pill: Swallowable, dueDate: Date, totalDue: Int) {
        self.pill = pill
        self.dueDate = dueDate
        self.title = PDNotificationStrings.takePill + pill.name
        super.init(title: self.title, body: self.body, badge: totalDue)
    }
    
    public func request() {
        let now = Date()
        super.content.categoryIdentifier = DuePillNotification.categoryId
        let interval = self.dueDate.timeIntervalSince(now)
        super.request(when: interval, requestId: self.pill.id.uuidString)
    }
}
