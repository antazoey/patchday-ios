//
//  AlertStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.

import Foundation

class AlertStrings {

    private static let titleComment = { return "Title for alert." }()
    private static let messageComment = { return "Message for alert." }()

    static var genericAlertStrings: (title: String, message: String) {
        (
            NSLocalizedString("PatchDay encountered a problem.", comment: titleComment),
            NSLocalizedString("Contact support@patchdayhrt.com for help.", comment: messageComment)
        )
    }

    static var loseDataAlertStrings: (title: String, message: String) {
        (
            NSLocalizedString("Warning", comment: titleComment),
            NSLocalizedString(
                "This action will result in a loss of data.",
                comment: messageComment
            )
        )
    }

    static var disclaimerAlertStrings: (
        title: String, message: String, supportPageActionTitle: String
        ) {
        (
            NSLocalizedString("Setup / Disclaimer", comment: titleComment),
            NSLocalizedString(
                "To begin using PatchDay, tap the Gear button in the " +
                "top right and set your Quantity, Schedule Interval, and Delivery Method." +
                "\n\nUse this tool responsibly, and please follow prescription instructions!" +
                "\n\nGo to www.PatchDayHRT.com to learn more.", comment: messageComment
            ),
            NSLocalizedString("Support page", comment: titleComment)
        )
    }

    static var newSiteAlertStrings: (
        title: String, positiveActionTitle: String, negativeActionTitle: String
        ) {
        (
            NSLocalizedString("Add new site name to sites list?", comment: titleComment),
            NSLocalizedString("Yes, add it!", comment: titleComment),
            NSLocalizedString("No, that's okay.", comment: titleComment)
        )
    }
}
