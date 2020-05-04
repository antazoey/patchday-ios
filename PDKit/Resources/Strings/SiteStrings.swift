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

	public static let CustomSiteId = "custom"

	public static var Unplaced: String { NSLocalizedString("unplaced", comment: commonComment) }

	public static var NewSite: String { NSLocalizedString("New Site", comment: commonComment) }

	public static var rightAbdomen: String {
		NSLocalizedString("Right Abdomen", tableName: nil, comment: commonComment)
	}

	public static var leftAbdomen: String {
		NSLocalizedString("Left Abdomen", tableName: nil, comment: commonComment)
	}

	public static var rightGlute: String {
		NSLocalizedString("Right Glute", tableName: nil, comment: commonComment)
	}

	public static var leftGlute: String {
		NSLocalizedString("Left Glute", tableName: nil, comment: commonComment)
	}

	public static var rightQuad: String {
		NSLocalizedString("Right Quad", comment: commonComment)
	}

	public static var leftQuad: String {
		NSLocalizedString("Left Quad", comment: commonComment)
	}

	public static var rightDelt: String {
		NSLocalizedString("Right Delt", comment: commonComment)
	}

	public static var leftDelt: String { NSLocalizedString("Left Delt", comment: commonComment) }

	public static var rightArm: String { NSLocalizedString("Right Arm", comment: commonComment) }

	public static var leftArm: String { NSLocalizedString("Left Arm", comment: commonComment) }

	public static var patches: [String] { [rightGlute, leftGlute, rightAbdomen, leftAbdomen] }

	public static var injections: [String] {
		[rightQuad, leftQuad, rightGlute, leftGlute, rightDelt, leftDelt]
	}

	public static var gels: [String] { [rightArm, leftArm] }

	public static func getSiteNames(for method: DeliveryMethod) -> [String] {
		switch method {
			case .Patches: return patches
			case .Injections: return injections
			case .Pills: return []
			case .Gel: return gels
		}
	}
}
