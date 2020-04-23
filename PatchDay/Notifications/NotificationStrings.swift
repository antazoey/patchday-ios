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

	static subscript(params: ExpiredHormoneNotificationCreationParams) -> (String, String) {
		var titleBuilder: String
		var titleOptions: [String]
		var bodyBuilder: String
		var siteBody: String
		switch params.deliveryMethod {
		case .Patches:
			titleOptions = [patchExpired, patchExpires]
			bodyBuilder = patchBody
			siteBody = siteForNextPatch
		case .Injections:
			titleOptions = [injectionExpired, injectionExpires]
			bodyBuilder = injectionBody
			siteBody = siteForNextInjection
		}
		titleBuilder = (params.notificationMinutesBefore == 0) ? titleOptions[0] : titleOptions[1]
		bodyBuilder += siteBody + params.expiringSiteName
		if let n = params.suggestedSiteName {
			bodyBuilder += siteBody + n
		}
		return (titleBuilder, bodyBuilder)
	}

	class Overnight {
		static subscript(method: DeliveryMethod) -> String {
			switch method {
			case .Patches: return overnightPatch
			case .Injections: return overnightInjection
			}
		}
	}

	// MARK: - User facing

	static let patchBody = {
		NSLocalizedString("Expired patch site: ", comment: comment)
	}()

	static let injectionBody = {
		NSLocalizedString("Your last injection site: ", comment: comment)
	}()

	static let siteForNextPatch = {
		NSLocalizedString("Site for next patch: ", comment: comment)
	}()

	static let siteForNextInjection = {
		NSLocalizedString("Site for next injection: ", comment: comment)
	}()

	static let autofill = {
		NSLocalizedString(
			"Change to suggested site?",
			comment: "Notification action label."
		)
	}()

	static let patchExpired = {
		NSLocalizedString("Time for your next patch", comment: comment)
	}()

	static let patchExpires = {
		NSLocalizedString("Almost time for your next patch", comment: comment)
	}()

	static let injectionExpired = {
		NSLocalizedString("Time for your next injection", comment: comment)
	}()

	static let injectionExpires = {
		NSLocalizedString(
			"Almost time for your next injection",
			comment: comment
		)
	}()

	static let takePill = {
		NSLocalizedString("Time to take pill: ", comment: comment)
	}()

	static let overnightPatch = {
		NSLocalizedString("Patch expires overnight.", comment: comment)
	}()

	static let overnightInjection = {
		NSLocalizedString("Injection due overnight", comment: comment)
	}()

	// MARK: - Comments

	private static let comment = { "Notification telling you where and " +
			"when to change your patch." }()

	private static let titleComment = { "Title of notification." }()
}
