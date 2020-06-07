//
//  SiteImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class SiteImages: NSObject {

	override public var description: String { "Read-only app image static accessor." }

	// Placeholder
	static var placeholderPatch: UIImage { initImage("Add Patch") }
	static var placeholderInjection: UIImage { initImage("Add Injection") }
	static var placeholderGel: UIImage { initImage("Add Gel") }

	// Patch site images
	static var patchRightGlute: UIImage { initImage(SiteStrings.RightGlute) }
	static var patchLeftGlute: UIImage { initImage(SiteStrings.LeftGlute) }
	static var patchRightAbdomen: UIImage { initImage(SiteStrings.RightAbdomen) }
	static var patchLeftAbdomen: UIImage { initImage(SiteStrings.LeftAbdomen) }
	static var customPatch: UIImage { initImage("Custom Patch") }

	// Injection site images
	static var lnjectionLeftQuad: UIImage { initImage(SiteStrings.LeftQuad) }
	static var lnjectionRightQuad: UIImage { initImage(SiteStrings.RightQuad) }
	static var lnjectionLeftGlute: UIImage { initImage("Left Injection Glute") }
	static var lnjectionGluteRight: UIImage { initImage("Right Injection Glute") }
	static var lnjectionLeftDelt: UIImage { initImage(SiteStrings.LeftDelt) }
	static var lnjectionRightDelt: UIImage { initImage(SiteStrings.RightDelt) }
	static var customInjection: UIImage { initImage("Custom Injection") }

	// Gel images
	static var arms: UIImage { initImage(SiteStrings.Arms) }
	static var customGel: UIImage { initImage("Custom Gel") }

	static var patchImages: [UIImage] {
		[patchRightGlute, patchLeftGlute, patchRightAbdomen, patchLeftAbdomen, customPatch]
	}

	static var injectionImages: [UIImage] {
		[
			lnjectionRightQuad,
			lnjectionLeftQuad,
			lnjectionLeftGlute,
			lnjectionGluteRight,
			lnjectionLeftDelt,
			lnjectionRightDelt,
			customInjection
		]
	}

	static var gelImages: [UIImage] {
		[arms]
	}

	public static var all: [UIImage] {
		Array(patchImages + injectionImages + gelImages)
	}

	public class All {
		public static subscript(method: DeliveryMethod) -> [UIImage] {
			switch method {
				case .Patches: return patchImages
				case .Injections: return injectionImages
				case .Gel: return gelImages
			}
		}
	}

	private static var imageToSiteNameDict: [UIImage: SiteName] {
		[
			patchRightGlute: SiteStrings.RightGlute,
			patchLeftGlute: SiteStrings.LeftGlute,
			patchRightAbdomen: SiteStrings.RightAbdomen,
			patchLeftAbdomen: SiteStrings.LeftAbdomen,
			lnjectionGluteRight: SiteStrings.RightGlute,
			lnjectionLeftGlute: SiteStrings.LeftGlute,
			lnjectionRightQuad: SiteStrings.RightQuad,
			lnjectionLeftQuad: SiteStrings.LeftQuad,
			lnjectionRightDelt: SiteStrings.RightDelt,
			lnjectionLeftDelt: SiteStrings.LeftDelt,
			arms: SiteStrings.Arms
		]
	}

	private static var siteNameToPatchImageDict: [SiteName: UIImage] {
		[
			SiteStrings.RightGlute: patchRightGlute,
			SiteStrings.LeftGlute: patchLeftGlute,
			SiteStrings.RightAbdomen: patchRightAbdomen,
			SiteStrings.LeftAbdomen: patchLeftAbdomen
		]
	}

	private static var siteNameToInjectionImageDict: [SiteName: UIImage] {
		[
			SiteStrings.RightGlute: lnjectionGluteRight,
			SiteStrings.LeftGlute: lnjectionLeftGlute,
			SiteStrings.RightDelt: lnjectionRightDelt,
			SiteStrings.LeftDelt: lnjectionLeftDelt,
			SiteStrings.RightQuad: lnjectionRightQuad,
			SiteStrings.LeftQuad: lnjectionLeftQuad
		]
	}

	private static var siteNameToGelImageDict: [SiteName: UIImage] {
		[SiteStrings.Arms: arms]
	}

	private static func initImage(_ name: String) -> UIImage {
		guard let image = UIImage(named: name) else { return UIImage() }
		image.accessibilityIdentifier = name
		return image
	}

	static func isPlaceholder(_ img: UIImage) -> Bool {
		img == placeholderPatch || img == placeholderInjection
	}

	/// Converts patch image to SiteName a.k.a String
	static func getName(from image: UIImage) -> SiteName {
		imageToSiteNameDict[image] ?? SiteStrings.NewSite
	}

	static subscript(params: SiteImageDeterminationParameters) -> UIImage {
		provided(from: params) ?? custom(from: params) ?? placeholder(params)
	}

	private static func provided(from params: SiteImageDeterminationParameters) -> UIImage? {
		guard let siteName = params.imageId else { return nil }
		switch params.deliveryMethod {
			case .Patches: return siteNameToPatchImageDict[siteName]
			case .Injections: return siteNameToInjectionImageDict[siteName]
			case .Gel: return siteNameToGelImageDict[siteName]
		}
	}

	private static func custom(from params: SiteImageDeterminationParameters) -> UIImage? {
		guard let _ = params.imageId else { return nil }
		switch params.deliveryMethod {
			case .Patches: return customPatch
			case .Injections: return customInjection
			default: return nil
		}
	}

	private static func placeholder(_ params: SiteImageDeterminationParameters) -> UIImage {
		switch params.deliveryMethod {
			case .Patches: return placeholderPatch
			case .Injections: return placeholderInjection
			case .Gel: return placeholderGel
		}
	}
}
