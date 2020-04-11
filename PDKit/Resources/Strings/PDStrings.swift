//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//


public class PlaceholderStrings {
    public static let NothingYet = {
        NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
    }()
    public static let DotDotDot = {
        NSLocalizedString("...", comment: "Instruction for empty patch")
    }()
}


public class DayStrings {
    private static let comment = "The word 'today' displayed on a button."
    public static var today: String {
        NSLocalizedString("Today", comment: comment)
    }
    public static var yesterday: String {
        NSLocalizedString("Yesterday", comment: comment)
    }
    public static var tomorrow: String {
        NSLocalizedString("Tomorrow", comment: comment)
    }
}


public enum TodayKey: String {
    case nextHormoneSiteName = "nextEstroSiteName"
    case nextHormoneDate = "nextEstroDate"
    case nextPillToTake = "nextPillToTake"
    case nextPillTakeTime = "nextPillTakeTime"
}


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
