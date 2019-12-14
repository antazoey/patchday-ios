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


public class ExpiredHormoneNotification : Notification, ExpiredHormoneNotifying {
    
    private let hormone: Hormonal
    private let expiration: ExpirationIntervalUD
    private let notificationsMinutesBefore: Double

    public static let actionId = "estroActionId"
    public static let categoryId = "estroCategoryId"
    
    init(_ params: ExpiredHormoneNotificationCreationParams) {
        self.hormone = params.hormone
        self.expiration = params.expiration
        self.notificationsMinutesBefore = params.notificationMinutesBefore
        let expName = hormone.siteName
        let strings = NotificationStrings.getHormoneNotificationStrings(
            method: params.deliveryMethod,
            minutesBefore: params.notificationMinutesBefore, expiringSiteName: expName
        )
        super.init(title: strings.0, body: strings.1, badge: params.totalHormonesExpired)
    }
    
    func request() {
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
