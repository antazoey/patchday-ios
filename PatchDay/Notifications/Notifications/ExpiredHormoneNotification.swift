//
//  ExpiredHormoneNotification .swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class ExpiredHormoneNotification : PDNotification, ExpiredHormoneNotifying {
    
    private let hormone: Hormonal
    private let expiration: ExpirationIntervalUD
    private let notificationsMinutesBefore: Double

    public static var actionId = { return "estroActionId" }()
    public static let categoryId = { return "estroCategoryId" }()
    
    public init(for hormone: Hormonal,
                deliveryMethod method: DeliveryMethod,
                expiration: ExpirationIntervalUD,
                notifyMinutesBefore minutes: Double,
                totalDue: Int) {
        self.hormone = hormone
        self.expiration = expiration
        self.notificationsMinutesBefore = minutes
        let expName = hormone.siteName
        let strs = NotificationStrings.getHormoneNotificationStrings(
            method: method,
            minutesBefore: minutes,expiringSiteName: expName
        )
        super.init(title: strs.0, body: strs.1, badge: totalDue)
    }
    
    public func request() {
        let hours = expiration.hours
        if var timeIntervalUntilExpire = DateHelper.calculateExpirationTimeInterval(hours, date: hormone.date) {
            timeIntervalUntilExpire = timeIntervalUntilExpire - (self.notificationsMinutesBefore * 60.0)
            if timeIntervalUntilExpire > 0 {
                let id = self.hormone.id.uuidString
                super.content.categoryIdentifier = ExpiredHormoneNotification.categoryId
                super.request(when: timeIntervalUntilExpire, requestId: id)
            }
        }
    }
}
