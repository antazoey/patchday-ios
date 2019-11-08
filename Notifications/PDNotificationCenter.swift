//
//  PDNotificationCenter.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

class PDNotificationCenter: NSObject, PDNotificationCenterDelegate {

    private let root: UNUserNotificationCenter
    private let applyHormone: ApplyHormoneNotificationActionHandling
    private let swallowPill: SwallowPillNotificationActionHandling
    
    init(
        root: UNUserNotificationCenter,
        applyHormoneAction: ApplyHormoneNotificationActionHandling,
        swallowAction: SwallowPillNotificationActionHandling
    ) {
        self.applyHormone = applyHormoneAction
        self.swallowPill = swallowAction
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
            title: PDActionStrings.autofill,
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
            title: PDActionStrings.take,
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

    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case ExpiredHormoneNotification.actionId :
            if let id = UUID(uuidString: response.notification.request.identifier),
                let suggestedsite = sdk.sites.suggested {

                sdk.setHormoneDateAndSite(for: id, date: Date(), site: suggestedsite)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        case DuePillNotification.actionId :
            if let uuid = UUID(uuidString: response.notification.request.identifier),
                let pill = sdk.pills.get(for: uuid) {

                
                sdk.swallow(pill)
                requestDuePillNotification(pill)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        default : return
        }
    }
}
