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
import PatchData

public class EstrogenNotification : PDNotification, PDNotifying {
    
    private let estrogen: MOEstrogen
    private let expirationInterval: ExpirationIntervalUD
    private let notificationsMinutesBefore: Double

    public static var actionId = { return "estroActionId" }()
    public static let categoryId = { return "estroCategoryId" }()
    
    public init(for estrogen: MOEstrogen,
                deliveryMethod method: DeliveryMethod,
                expirationInterval: ExpirationIntervalUD,
                notifyMinutesBefore minutes: Double,
                totalDue: Int) {
        self.estrogen = estrogen
        self.expirationInterval = expirationInterval
        self.notificationsMinutesBefore = minutes
        let expName = estrogen.getSiteName()
        let strs = PDNotificationStrings.getEstrogenNotificationStrings(method: method,
                                                                        minutesBefore: minutes,
                                                                        expiringSiteName: expName)
        super.init(title: strs.0, body: strs.1, badge: totalDue)
    }
    
    public func request() {
        let hours = expirationInterval.hours
        if let date = estrogen.getDate(),
            var timeIntervalUntilExpire = PDDateHelper.expirationInterval(hours, date: date as Date) {
            timeIntervalUntilExpire = timeIntervalUntilExpire - (self.notificationsMinutesBefore * 60.0)
            if timeIntervalUntilExpire > 0, let id = self.estrogen.getId() {
                super.content.categoryIdentifier = EstrogenNotification.categoryId
                super.request(when: timeIntervalUntilExpire, requestId: id.uuidString)
            }
        }
    }
}
