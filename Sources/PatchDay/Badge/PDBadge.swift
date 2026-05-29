//
//  PDBadge.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.

import UIKit
import UserNotifications
import PDKit

public class PDBadge: PDBadgeReflective {

    private let sdk: PatchDataSDK?

    // PDBadge is the only place in the app that writes the icon badge, so we
    // cache the last-set value here. iOS 17 removed
    // `UIApplication.applicationIconBadgeNumber`; its replacement
    // (`UNUserNotificationCenter.setBadgeCount`) provides no getter.
    private static var lastSetValue: Int = 0

    public init(sdk: PatchDataSDK?) {
        self.sdk = sdk
    }

    public func reflect() {
        let newValue = sdk?.totalAlerts ?? 0
        setBadge(to: newValue)
        PDLog<PDBadge>().info("Badge number set to \(newValue)")
    }

    public func clear() {
        setBadge(to: 0)
    }

    public var value: Int {
        PDBadge.lastSetValue
    }

    private func setBadge(to newValue: Int) {
        PDBadge.lastSetValue = newValue
        UNUserNotificationCenter.current().setBadgeCount(newValue) { error in
            if let error = error {
                PDLog<PDBadge>().error("Failed to set badge count", error)
            }
        }
    }
}
