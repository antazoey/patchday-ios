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

    public class Intervals {
        private static let comment = "Picker option."
        public static var EveryDay: String {
            NSLocalizedString("Every Day", comment: comment)
        }
        public static var EveryOtherDay: String {
            NSLocalizedString("Every Other Day", comment: comment)
        }
        public static var FirstTenDays: String {
            NSLocalizedString("First 10 Days / Month", comment: comment)
        }
        public static var LastTenDays: String {
            NSLocalizedString("Last 10 Days / Month", comment: comment)
        }
        public static var FirstTwentyDays: String {
            NSLocalizedString("First 20 Days / Month", comment: comment)
        }
        public static var LastTwentyDays: String {
            NSLocalizedString("Last 20 Days / Month", comment: comment)
        }

        public static var all: [String] {
            [
                EveryDay,
                EveryOtherDay,
                FirstTenDays,
                LastTenDays,
                FirstTwentyDays,
                LastTwentyDays
            ]
        }

        public static func getStringFromInterval(_ interval: PillExpirationInterval) -> String {
            switch interval {
            case .EveryDay: return EveryDay
            case .EveryOtherDay: return EveryOtherDay
            case .FirstTenDays: return FirstTenDays
            case .LastTenDays: return LastTenDays
            case .FirstTwentyDays: return FirstTwentyDays
            case .LastTwentyDays: return LastTwentyDays
            }
        }

        public static func getIntervalFromString(_ string: String) -> PillExpirationInterval? {
            switch string {
            case EveryDay: return .EveryDay
            case EveryOtherDay: return .EveryOtherDay
            case FirstTenDays: return .FirstTenDays
            case LastTenDays: return .LastTenDays
            case FirstTwentyDays: return .FirstTwentyDays
            case LastTwentyDays: return .LastTwentyDays
            default: return nil
            }
        }
    }
}
