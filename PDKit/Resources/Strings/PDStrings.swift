//
//  PDStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDStrings: NSObject {
    
    override public var description: String {
        "Read-only class for PatchDay Strings."
    }
    
    // MARK: - Days (Localizable)
    
    public struct DayStrings {
        private static let comment = "The word 'today' displayed on a button."
        public static let today = {
            NSLocalizedString("Today", comment: comment)
        }()
        public static let yesterday = {
            NSLocalizedString("Yesterday", comment: comment)
        }()
        public static let tomorrow = {
            NSLocalizedString("Tomorrow", comment: comment)
        }()
    }
    
    // MARK: - PlaceHolders
    
    public class PlaceholderStrings {
        
        private static let c1 = "On buttons with plenty of room"
        private static let c2 = "Instruction for empty patch"
        private static let c3 = "Probably won't be seen by users, so don't worry too much."
        private static let c4 = "Displayed under a button with medium room."
        
        public static let nothingYet = {
            NSLocalizedString("Nothing yet", comment: c1)
        }()
        public static let dotDotDot = {
            NSLocalizedString("...", comment: c2)
        }()
        public static let newPill = {
            NSLocalizedString("New Pill", comment: c4)
        }()
    }

    // MARK: - User default keys
    
    public enum TodayKey: String {
        case nextHormoneSiteName = "nextEstroSiteName"
        case nextHormoneDate = "nextEstroDate"
        case nextPillToTake = "nextPillToTake"
        case nextPillTakeTime = "nextPillTakeTime"
    }
    
    public struct PillTypes {
        public static let defaultPills = { ["T-Blocker", "Progesterone"] }()
        public static let extraPills = { ["Estrogen", "Prolactin"] }()
    }
    
    // MARK: - Color keys

    public enum ColorKey: String {
        case OffWhite = "whitish"
        case LightBlue = "blue"
        case Gray = "cute_gray"
        case LightGray = "light_cute_gray"
        case Green = "green"
        case Pink = "pink"
        case Purple = "purple"
        case Black = "black"
    }
}
