//
//  PDNotificationCenter.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.

import Foundation
import UserNotifications
import PDKit

class PDNotificationCenter: NSObject, NotificationCenterDelegate {

    private let root: UNUserNotificationCenter
    private lazy var log = PDLog<PDNotificationCenter>()
    var pillActionHandler: PillNotificationActionHandling

    init(
        root: UNUserNotificationCenter,
        handlePill: PillNotificationActionHandling
    ) {
        self.pillActionHandler = handlePill
        self.root = root
        super.init()
        self.root.delegate = self
        self.root.setNotificationCategories(categories)
        requestAuthorizationIfNotDetermined()
    }

    private func requestAuthorizationIfNotDetermined() {
        root.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            guard settings.authorizationStatus == .notDetermined else { return }
            self.root.requestAuthorization(options: [.alert, .sound, .badge]) { (_, error) in
                if let e = error {
                    self.log.error(e)
                }
            }
        }
    }

    private var categories: Set<UNNotificationCategory> {
        let pillActionId = DuePillNotification.actionId
        let pillAction = UNNotificationAction(
            identifier: pillActionId,
            title: ActionStrings.Take,
            options: []
        )
        let pillCatId = DuePillNotification.categoryId
        let pillCategory = UNNotificationCategory(
            identifier: pillCatId,
            actions: [pillAction],
            intentIdentifiers: [],
            options: []
        )
        return Set([pillCategory])
    }

    func removeNotifications(with ids: [String]) {
        root.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// How a notification is shown when it fires while the app is in the
    /// foreground. Without presenting here, the system silently drops
    /// foreground notifications — which on a Mac (where the app window is
    /// usually open/foreground) means notifications never appear at all.
    static let foregroundPresentationOptions: UNNotificationPresentationOptions =
        [.banner, .list, .sound, .badge]

    /// Present notifications even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(Self.foregroundPresentationOptions)
    }

    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }
        let id = response.notification.request.identifier
        switch response.actionIdentifier {
            case DuePillNotification.actionId: pillActionHandler.handlePill(pillId: id)
            default: return
        }
    }
}
