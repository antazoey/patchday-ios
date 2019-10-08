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

    private let sdk: PatchDataDelegate
    private let root: UNUserNotificationCenter
    
    init(sdk: PatchDataDelegate, root: UNUserNotificationCenter) {
        self.sdk = sdk
        self.root = root
        super.init()
        self.root.delegate = self
        self.root.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in if (error != nil) { print(error as Any) }
        }
        self.root.setNotificationCategories(categories)
    }
    
    private var categories: Set<UNNotificationCategory> {
        let estroActionId = ExpiredHormoneNotification.actionId
        let estrogenAction = UNNotificationAction(identifier: estroActionId,
                                                  title: PDActionStrings.autofill,
                                                  options: [])
        let estroCatId = ExpiredHormoneNotification.categoryId
        let estrogenCategory = UNNotificationCategory(identifier: estroCatId,
                                                      actions: [estrogenAction],
                                                      intentIdentifiers: [],
                                                      options: [])
        let pillActionId = DuePillNotification.actionId
        let pillAction = UNNotificationAction(identifier: pillActionId,
                                                  title: PDActionStrings.take,
                                                  options: [])
        let pillCatId = DuePillNotification.categoryId
        let pillCategory = UNNotificationCategory(identifier: pillCatId,
                                                  actions: [pillAction],
                                                  intentIdentifiers: [],
                                                  options: [])
        return Set([estrogenCategory, pillCategory])
    }

    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case ExpiredHormoneNotification.actionId :
            if let id = UUID(uuidString: response.notification.request.identifier),
                let suggestedsite = sdk.sites.suggested {

                sdk.setEstrogenDateAndSite(for: id, date: Date(), site: suggestedsite)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        case DuePillNotification.actionId :
            if let uuid = UUID(uuidString: response.notification.request.identifier),
                let pill = sdk.pills.get(for: uuid) {

                sdk.swallow(pill)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        default : return
        }
    }
    
    func removeNotifications(with ids: [String]) {
        root.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
