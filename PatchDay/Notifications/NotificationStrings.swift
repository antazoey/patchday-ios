//
//  NotificationStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class NotificationStrings {

	static let siteToExpiredPatchMessage =
		[
			"Right Abdomen": NSLocalizedString(
				"Change patch on your 'Right Abdomen'",
				comment: comment
			),
			"Left Abdomen": NSLocalizedString(
				"Change patch on your 'Right Abdomen'",
				comment: comment
			),
			"Right Glute": NSLocalizedString(
				"Change patch on your 'Right Glute'",
				comment: comment
			),
			"Left Glute": NSLocalizedString(
				"Change patch on your 'Left Glute'",
				comment: comment
			)
		]

    static func get(
        method: DeliveryMethod,
        notifyMinutes: Double,
        siteName: SiteName,
        suggestedSite: SiteName?
    ) -> (String, String) {
        let titleOptions = method == .Patches ? [patchExpired, patchExpires] : [injectionExpired, injectionExpires]
		let title = (notifyMinutes == 0) ? titleOptions[0] : titleOptions[1]
        let body = suggestedSite != nil ? "\(suggestedNextSite) \(suggestedSite!)" : ""
		return (title, body)
	}

	class Overnight {
		static subscript(method: DeliveryMethod) -> String {
			switch method {
				case .Patches: return overnightPatch
				case .Injections: return overnightInjection
				default: return ""
			}
		}
	}

	// MARK: - User facing

    static var suggestedNextSite: String {
		NSLocalizedString("Suggested next site:", comment: comment)
    }

    static var autofill: String {
		NSLocalizedString(
			"Change to suggested site?",
			comment: "Notification action label."
		)
	}

    static var patchExpired: String {
		NSLocalizedString("Time for your next patch", comment: comment)
	}

    static var patchExpires: String {
		NSLocalizedString("Almost time for your next patch", comment: comment)
	}

    static var injectionExpired: String {
		NSLocalizedString("Time for your next injection", comment: comment)
	}

    static var injectionExpires: String {
		NSLocalizedString(
			"Almost time for your next injection",
			comment: comment
		)
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

    private static let comment = "Notification telling you where and when to change your patch."
	private static let titleComment = "Title of notification."
}
