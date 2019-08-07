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
import PatchData

public class PillNotification : PDNotification, PDNotifying {
    
    private let pill: MOPill
    private let dueDate: Date
    
    public var title: String
    public var body: String?
    public static var actionId = { return "takeActionId" }()
    public static var categoryId = { return "pillCategoryId" }()
    
    init(for pill: MOPill, dueDate: Date, totalDue: Int) {
        self.pill = pill
        self.dueDate = dueDate
        self.title = PDNotificationStrings.takePill + (pill.getName() ?? "")
        super.init(title: self.title, body: self.body, badge: totalDue)
    }
    
    public func request() {
        let now = Date()
        super.content.categoryIdentifier = PillNotification.categoryId
        let interval = self.dueDate.timeIntervalSince(now)
        if let id = self.pill.getId() {
            super.request(when: interval, requestId: id.uuidString)
        }
    }
}
