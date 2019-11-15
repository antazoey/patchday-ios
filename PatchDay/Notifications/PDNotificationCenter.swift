//
//  NotificationCenter.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

class PDNotificationCenter: NSObject, NotificationCenterDelegate {

    private let root: UNUserNotificationCenter
    private let hormoneApplicant: ApplyHormoneNotificationActionHandling
    private let pillSwallower: SwallowPillNotificationActionHandling
    
    init(
        root: UNUserNotificationCenter,
        applyHormoneHandler: ApplyHormoneNotificationActionHandling,
        swallowPillHandler: SwallowPillNotificationActionHandling
    ) {
        self.hormoneApplicant = applyHormoneHandler
        self.pillSwallower = swallowPillHandler
        self.root = root
        super.init()
        self.root.delegate = self
        self.root.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (error != nil) {
                print(error as Any)
            }
        }
        self.root.setNotificationCategories(categories)
    }
    
    private var categories: Set<UNNotificationCategory> {
        let hormoneActionId = ExpiredHormoneNotification.actionId
        let hormoneAction = UNNotificationAction(
            identifier: hormoneActionId,
            title: ActionStrings.autofill,
            options: []
        )
        let hormoneCatId = ExpiredHormoneNotification.categoryId
        let hormoneCategory = UNNotificationCategory(
            identifier: hormoneCatId,
            actions: [hormoneAction],
            intentIdentifiers: [],
            options: []
        )
        let pillActionId = DuePillNotification.actionId
        let pillAction = UNNotificationAction(
            identifier: pillActionId,
            title: ActionStrings.take,
            options: []
        )
        let pillCatId = DuePillNotification.categoryId
        let pillCategory = UNNotificationCategory(
            identifier: pillCatId,
            actions: [pillAction],
            intentIdentifiers: [],
            options: []
        )
        return Set([hormoneCategory, pillCategory])
    }
    
    func removeNotifications(with ids: [String]) {
        root.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let uid = response.notification.request.identifier
        switch response.actionIdentifier {
        case ExpiredHormoneNotification.actionId :
            hormoneApplicant.applyHormone(hormoneUid: uid)
        case DuePillNotification.actionId :
            pillSwallower.swallow(pillUid: uid)
        default : return
        }
    }
}
