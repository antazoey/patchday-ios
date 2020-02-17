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
        
        public static let NothingYet = {
            NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
        }()
        public static let DotDotDot = {
            NSLocalizedString("...", comment: "Instruction for empty patch")
        }()
    }

    // MARK: - User default keys
    
    public enum TodayKey: String {
        case nextHormoneSiteName = "nextEstroSiteName"
        case nextHormoneDate = "nextEstroDate"
        case nextPillToTake = "nextPillToTake"
        case nextPillTakeTime = "nextPillTakeTime"
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
