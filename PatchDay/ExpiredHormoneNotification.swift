//
//  EstrogenNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class ExpiredHormoneNotification : PDNotification, PDNotifying {
    
    private let hormone: Hormonal
    private let expirationInterval: ExpirationIntervalUD
    private let notificationsMinutesBefore: Double

    public static var actionId = { return "estroActionId" }()
    public static let categoryId = { return "estroCategoryId" }()
    
    public init(for hormone: Hormonal,
                deliveryMethod method: DeliveryMethod,
                expirationInterval: ExpirationIntervalUD,
                notifyMinutesBefore minutes: Double,
                totalDue: Int) {
        self.hormone = hormone
        self.expirationInterval = expirationInterval
        self.notificationsMinutesBefore = minutes
        let expName = hormone.siteName
        let strs = PDNotificationStrings.getHormoneNotificationStrings(
            method: method,
            minutesBefore: minutes,expiringSiteName: expName
        )
        super.init(title: strs.0, body: strs.1, badge: totalDue)
    }
    
    public func request() {
        let hours = expirationInterval.hours
        if var timeIntervalUntilExpire = PDDateHelper.expirationInterval(hours, date: hormone.date) {
            timeIntervalUntilExpire = timeIntervalUntilExpire - (self.notificationsMinutesBefore * 60.0)
            if timeIntervalUntilExpire > 0 {
                let id = self.hormone.id.uuidString
                super.content.categoryIdentifier = ExpiredHormoneNotification.categoryId
                super.request(when: timeIntervalUntilExpire, requestId: id)
            }
        }
    }
}
