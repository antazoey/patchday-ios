//
//  SiteStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 5/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class SiteStrings {

	private static let commonComment = {
		"Displayed all over the app. Abbreviate if it is more than 2x as long."
	}()

	private static var rightGlute: String {
		NSLocalizedString("Right Glute", tableName: nil, comment: commonComment)
	}

	private static var leftGlute: String {
		NSLocalizedString("Left Glute", tableName: nil, comment: commonComment)
	}

	public static var Unplaced: String { NSLocalizedString("unplaced", comment: commonComment) }

	public static var NewSite: String { NSLocalizedString("New Site", comment: commonComment) }

	public static let CustomSiteId = "custom"

	public static var patches: [String] {
		[
			rightGlute,
			leftGlute,
			NSLocalizedString("Right Abdomen", tableName: nil, comment: commonComment),
			NSLocalizedString("Left Abdomen", tableName: nil, comment: commonComment)
		]
	}

	public static var injections: [String] {
		[
			NSLocalizedString("Right Quad", comment: commonComment),
			NSLocalizedString("Left Quad", comment: commonComment),
			rightGlute,
			leftGlute,
			NSLocalizedString("Right Delt", comment: commonComment),
			NSLocalizedString("Left Delt", comment: commonComment)
		]
	}

	public static var gels: [String] {
		[
			NSLocalizedString("Right Arm", comment: commonComment),
			NSLocalizedString("Left Arm", comment: commonComment)
		]
	}

	public static func getSiteNames(for method: DeliveryMethod) -> [String] {
		switch method {
		case .Patches: return patches
		case .Injections: return injections
		case .Pills: return []
		case .Gel: return [""]
		}
	}
}
