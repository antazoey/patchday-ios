//
//  PillStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 2/15/20.

import Foundation

public class PillStrings {

    public static var NewPill: String {
        NSLocalizedString("New Pill", comment: "Displayed under a button with medium room.")
    }

    public static var NotYetTaken: String {
        NSLocalizedString(
            " - ", comment: "Short as possible. Replace with just '...' if too long."
        )
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

        public static var FirstXDays: String {
            NSLocalizedString("First X Days of Month", comment: comment)
        }

        public static var LastXDays: String {
            NSLocalizedString("Last X Days of Month", comment: comment)
        }

        public static var XDaysOnXDaysOff: String {
            NSLocalizedString("X Days On, X Days Off", comment: comment)
        }

        public static var all: [String] {
            [
                EveryDay,
                EveryOtherDay,
                FirstXDays,
                LastXDays,
                XDaysOnXDaysOff
            ]
        }

        public static func getStringFromInterval(
            _ interval: PillExpirationIntervalSetting
        ) -> String {
            switch interval {
                case .EveryDay: return EveryDay
                case .EveryOtherDay: return EveryOtherDay
                case .XDaysOnXDaysOff: return XDaysOnXDaysOff
                case .FirstXDays: return FirstXDays
                case .LastXDays: return LastXDays
            }
        }

        public static func getIntervalFromString(
            _ string: String
        ) -> PillExpirationIntervalSetting? {
            switch string {
                case EveryDay: return .EveryDay
                case EveryOtherDay: return .EveryOtherDay
                case FirstXDays: return .FirstXDays
                case LastXDays: return .LastXDays
                case XDaysOnXDaysOff: return .XDaysOnXDaysOff
                default: return nil
            }
        }
    }
}
