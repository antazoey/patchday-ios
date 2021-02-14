//
//  NotificationStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.

import Foundation
import PDKit

class NotificationStrings {

    let title: String
    let body: String

    init(hormone: Hormonal) {
        self.body = NotificationStrings.createBody(from: hormone)
        self.title = NotificationStrings.createTitle(method: hormone.deliveryMethod)
    }

    static func createBody(from hormone: Hormonal) -> String {
        let type = SiteStrings.getDeliveryMethodString(hormone.deliveryMethod)
        return NSLocalizedString(
            "Expired \(type) from previous site \(hormone.siteName).",
            comment: "Notification body."
        )
    }

    static func createTitle(method: DeliveryMethod) -> String {
        switch method {
            case .Patches: return patchExpired
            case .Injections: return injectionExpired
            case .Gel: return gelExpired
        }
    }

    class Overnight {
        static subscript(method: DeliveryMethod) -> String {
            switch method {
                case .Patches: return overnightPatch
                case .Injections: return overnightInjection
                case .Gel: return overnightGel
            }
        }
    }

    // MARK: - User facing

    static var patchExpired: String {
        NSLocalizedString("Time for your next patch", comment: comment)
    }

    static var injectionExpired: String {
        NSLocalizedString("Time for your next injection", comment: comment)
    }

    static var gelExpired: String {
        NSLocalizedString("Time for your gel", comment: comment)
    }

    static var takePill: String {
        NSLocalizedString("Time to take pill: ", comment: comment)
    }

    static var overnightPatch: String {
        NSLocalizedString("Patch expires overnight.", comment: comment)
    }

    static var overnightInjection: String {
        NSLocalizedString("Injection due overnight.", comment: comment)
    }

    static var overnightGel: String {
        NSLocalizedString("Gel due overnight", comment: comment)
    }

    private static let comment = "Notification telling you where and when to change your patch."
    private static let titleComment = "Title of notification."
}
