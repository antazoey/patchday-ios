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

	public static let Unplaced = { NSLocalizedString("unplaced", comment: commonComment) }()

	public static let NewSite = { NSLocalizedString("New Site", comment: commonComment) }()

	public static let CustomSiteId = "custom"

	public static var patches: [String] {
		[
			NSLocalizedString("Right Glute", tableName: nil, comment: commonComment),
			NSLocalizedString("Left Glute", tableName: nil, comment: commonComment),
			NSLocalizedString("Right Abdomen", tableName: nil, comment: commonComment),
			NSLocalizedString("Left Abdomen", tableName: nil, comment: commonComment)
		]
	}

	public static var injections: [String] {
		[
			NSLocalizedString("Right Quad", comment: commonComment),
			NSLocalizedString("Left Quad", comment: commonComment),
			NSLocalizedString("Right Glute", comment: commonComment),
			NSLocalizedString("Left Glute", comment: commonComment),
			NSLocalizedString("Right Delt", comment: commonComment),
			NSLocalizedString("Left Delt", comment: commonComment)
		]
	}

	public static let rightAbdomen = { patches[2] }()
	public static let leftAbdomen = { patches[3] }()
	public static let rightGlute = { patches[0] }()
	public static let leftGlute = { patches[1] }()

	public static let rightQuad = { injections[0] }()
	public static let leftQuad = { injections[1] }()
	public static let rightDelt = { injections[4] }()
	public static let leftDelt = { injections[5] }()

	public static func getSiteNames(for method: DeliveryMethod) -> [String] {
		switch method {
		case .Patches: return patches
		case .Injections: return injections
		}
	}
}
