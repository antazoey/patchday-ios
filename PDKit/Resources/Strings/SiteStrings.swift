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

	public static var Arms: String {
		NSLocalizedString("Arms", comment: commonComment)
	}

	public static var RightAbdomen: String {
		NSLocalizedString("Right Abdomen", tableName: nil, comment: commonComment)
	}

	public static var LeftAbdomen: String {
		NSLocalizedString("Left Abdomen", tableName: nil, comment: commonComment)
	}

	public static var RightGlute: String {
		NSLocalizedString("Right Glute", tableName: nil, comment: commonComment)
	}

	public static var LeftGlute: String {
		NSLocalizedString("Left Glute", tableName: nil, comment: commonComment)
	}

	public static var RightQuad: String {
		NSLocalizedString("Right Quad", comment: commonComment)
	}

	public static var LeftQuad: String {
		NSLocalizedString("Left Quad", comment: commonComment)
	}

	public static var RightDelt: String {
		NSLocalizedString("Right Delt", comment: commonComment)
	}

	public static var LeftDelt: String { NSLocalizedString("Left Delt", comment: commonComment) }

	public static var RightArm: String { NSLocalizedString("Right Arm", comment: commonComment) }

	public static var LeftArm: String { NSLocalizedString("Left Arm", comment: commonComment) }

	public static var patches: [String] { [RightGlute, LeftGlute, RightAbdomen, LeftAbdomen] }

	public static var injections: [String] {
		[RightQuad, LeftQuad, RightGlute, LeftGlute, RightDelt, LeftDelt]
	}

	public static var gels: [String] { [Arms] }

	public static func getSiteNames(for method: DeliveryMethod) -> [String] {
		switch method {
			case .Patches: return patches
			case .Injections: return injections
			case .Gel: return gels
		}
	}
}
