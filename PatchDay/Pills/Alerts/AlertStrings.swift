//
//  AlertStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

class AlertStrings {

	private static let titleComment = { return "Title for alert." }()
	private static let messageComment = { return "Message for alert." }()

	static var genericAlertStrings: (title: String, message: String) {
		(NSLocalizedString("PatchDay encountered a problem.", comment: titleComment),
			NSLocalizedString("You may report the problem to support@patchdayhrt.com if you'd like.",
				comment: messageComment))
	}

	static var loseDataAlertStrings: (title: String, message: String) {
		(NSLocalizedString("Warning", comment: titleComment),
			NSLocalizedString("This action will result in a loss of data.",
				comment: messageComment))
	}

	static var disclaimerAlertStrings: (title: String, message: String, supportPageActionTitle: String) {
		(NSLocalizedString("Setup / Disclaimer", comment: titleComment),
			NSLocalizedString("To begin using PatchDay, tap the Edit button in the " +
					"top right and setup your schedule.\n\nUse this tool responsibly, " +
					"and please follow medication instructions!\n\nGo to www.PatchDayHRT.com " +
					"to learn more.", comment: messageComment),
			NSLocalizedString("Support page", comment: titleComment))
	}

	static var newSiteAlertStrings: (title: String, positiveActionTitle: String, negativeActionTitle: String) {
		(NSLocalizedString("Add new site name to sites list?", comment: titleComment),
			NSLocalizedString("Yes, add it!", comment: titleComment),
			NSLocalizedString("No, that's okay.", comment: titleComment))
	}
}
