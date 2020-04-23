//
//  PillStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 2/15/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public class PillStrings {

	public static var NewPill: String {
		NSLocalizedString("New Pill", comment: "Displayed under a button with medium room.")
	}

	public static var NotYetTaken: String {
		NSLocalizedString("Not yet taken", comment: "Short as possible. Replace with just '...' if too long.")
	}

	public static var DefaultPills: [String] { ["T-Blocker", "Progesterone"] }

	public static var ExtraPills: [String] { ["Estrogen", "Prolactin"] }
}
