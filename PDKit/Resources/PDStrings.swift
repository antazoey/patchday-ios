//
//  PDStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDStrings: NSObject {
    
    override public var description: String {
        return "Read-only class for PatchDay Strings."
    }
    
    /**********************************
        LOCALIZABLE
    **********************************/
    
    // MARK: - Actions (Localizable)
    
    public struct ActionStrings {
        private static let c1 = "Button title.  Could you keep it short?"
        private static let c2 = "Notification action. Used all over app, so please keep it short."
        private static let c3 = "Title for button, not too much room left for a really long word."
        private static let c4 = "Button title.  Room is fair."
        private static let c5 = "Button title.  Could you keep it short?"
        private static let c6 = "Alert action. Room is not an issue."
        private static let c7 = "Nav bar item title.  Could you keep it short?"
        public static let done = {
            return NSLocalizedString("Done", comment: c1)
        }()
        public static let delete = {
            return NSLocalizedString("Delete", comment: c1)
        }()
        public static let take = {
            return NSLocalizedString("Take", comment: c2)
        }()
        public static let taken = {
            return NSLocalizedString("Taken", comment: c3)
        }()
        public static let save = {
            return NSLocalizedString("Save", comment: c4)
        }()
        public static let undo = {
            return NSLocalizedString("undo", comment: c4)
        }()
        public static let autofill = {
            return NSLocalizedString("Autofill", comment: c4)
        }()
        public static let type = {
            return NSLocalizedString("Type", comment: c5)
        }()
        public static let select = {
            return NSLocalizedString("Select", comment: c5)
        }()
        public static let dismiss = {
            return NSLocalizedString("Dismiss", comment: c5)
        }()
        public static let accept = {
            return NSLocalizedString("Accept", comment: c6)
        }()
        public static let cont = {
            return NSLocalizedString("Continue", comment: c6)
        }()
        public static let decline = {
            return NSLocalizedString("Decline", comment: c6)
        }()
        public static let yes = {
            return NSLocalizedString("Yes", comment: c6)
        }()
        public static let no = {
            return NSLocalizedString("No", comment: c6)
        }()
        public static let edit = {
            return NSLocalizedString("Edit", comment: c7)
        }()
        public static let reset = {
            return NSLocalizedString("Reset", comment: c7)
        }()
    }
    
    // MARK: - Days (Localizable)
    
    public struct DayStrings {
        private static let comment = "The word 'today' displayed on a button."
        public static let today = {
            return NSLocalizedString("Today", comment: comment)
        }()
        public static let yesterday = {
            return NSLocalizedString("Yesterday", comment: comment)
        }()
        public static let tomorrow = {
            return NSLocalizedString("Tomorrow", comment: comment)
        }()
    }

    // MARK: - Alerts (Localizable)
    
    public struct AlertStrings {
        private static let titleComment = "Title for alert."
        private static let messageComment = "Message for alert."
        public struct CoreDataAlert {
            private static let msg = "PatchDay's storage is not working. " +
                "You may report the problem to support@patchdayhrt.com if you'd like."
            public static let title = {
                return NSLocalizedString("Data Error", comment: titleComment) }()
            public static let message = { return NSLocalizedString(msg, comment: messageComment)
            }()
        }
        
        public struct LoseDataAlert {
            private static let msg = "This action will result in a loss of data."
            public static let title = {
                return NSLocalizedString("Warning", comment: titleComment)
            }()
            public static let message = {
                return NSLocalizedString(msg, comment: messageComment)
            }()
        }
        
        public struct StartUp  {
            private static let msg =
                "To begin using PatchDay, tap the Edit button in the " +
                "top right and setup your schedule.\n\nUse this tool responsibly, " +
                "and please follow medication instructions!\n\nGo to www.PatchDayHRT.com " +
                "to learn more."
            public static let title = {
                return NSLocalizedString("Setup / Disclaimer", comment: titleComment)
            }()
            public static let message = {
                return NSLocalizedString(msg, comment: messageComment)
            }()
            public static let support = {
                return NSLocalizedString("Support page", comment: titleComment)
            }()
        }
        
        public struct AddSite {
            public static let title = {
                return NSLocalizedString("Add new site name to sites list?",
                                         comment: titleComment)
            }()
            public static let addActionTitle = {
                return NSLocalizedString("Yes, add it!", comment: titleComment)
            }()
            public static let declineActionTitle = {
                return NSLocalizedString("No, that's okay.", comment: titleComment)
            }()
        }
    }
    
    // MARK: - Placeholders (Localizable)
    
    public struct PlaceholderStrings {
        private static let c1 = "On buttons with plenty of room"
        private static let c2 = "Instruction for empty patch"
        private static let c3 = "Probably won't be seen by users, so don't worry too much."
        private static let c4 = "Displayed under a button with medium room."
        public static let nothing_yet = {
            return NSLocalizedString("Nothing yet", comment: c1)
        }()
        public static let dotdotdot = {
            return NSLocalizedString("...", comment: c2)
        }()
        public static let new_site = {
            return NSLocalizedString("New Site", comment: c3)
        }()
        public static let new_pill = {
            return NSLocalizedString("New Pill", comment: c4)
        }()
    }
    
    // MARK: - VC Titles
    
    public struct VCTitles {
        private static let comment = "Title of a view controller. Keep it brief."
        public static let patches = {
            return NSLocalizedString("Patches", comment: comment)
        }()
        public static let injections = {
            return NSLocalizedString("Injections", comment: comment)
        }()
        public static let settings = {
            return NSLocalizedString("Settings", comment: comment)
        }()
        public static let pills = {
            return NSLocalizedString("Pills", comment: comment)
        }()
        public static let pill_edit = {
            return NSLocalizedString("Edit Pill", comment: comment)
        }()
        public static let pill_new = {
            return NSLocalizedString("New Pill", comment: comment)
        }()
        public static let sites = {
            return NSLocalizedString("Sites", comment: comment)
        }()
        public static let patch_sites = {
            return NSLocalizedString("Patch Sites", comment: comment)
        }()
        public static let injection_sites = {
            return NSLocalizedString("Injection Sites", comment: comment)
        }()
        public static let site_edit = {
            return NSLocalizedString("Edit Site", comment: comment)
        }()
        public static let site_new = {
            return NSLocalizedString("New Site", comment: comment)
        }()
        public static let patch = {
            return NSLocalizedString("Patch", comment: comment)
        }()
        public static let injection = {
            return NSLocalizedString("Injection", comment: comment)
        }()
        public static let site = {
            return NSLocalizedString("Site", comment: comment)
        }()
    }
    
    // MARK: - Coloned strings (Localizable)
    
    public struct ColonedStrings {
        private static let comment1 = "Displayed on a label, plenty of room."
        private static let comment2 = "Label next to date. Easy on room."
        public static let count = {
            return NSLocalizedString("Count:", comment: comment1)
        }()
        public static let time = {
            return NSLocalizedString("Time:", comment: comment1)
        }()
        public static let first_time = {
            return NSLocalizedString("First time:", comment: comment1)
        }()
        public static let expires = {
            return NSLocalizedString("Expires: ", comment: comment2)
        }()
        public static let expired = {
            return NSLocalizedString("Expired: ", comment: comment2)
        }()
        public static let last_injected = {
            return NSLocalizedString("Injected: ", comment: comment2)
        }()
        public static let next_due = {
            return NSLocalizedString("Next due: ", comment: comment2)
        }()
        public static let date_and_time_applied = {
            return NSLocalizedString("Date and time applied: ", comment: comment2)
        }()
        public static let date_and_time_injected = {
            return NSLocalizedString("Date and time injected: ", comment: comment2)
        }()
        public static let site = {
            return NSLocalizedString("Site: ", comment: comment2)
        }()
        public static let last_site_injected = {
            return NSLocalizedString("Site injected: ", comment: comment2)
        }()
    }
    
    // Non-Localizable
    
    // MARK: - Core data keys
    
    public struct CoreDataKeys {
        public static let persistantContainer_key = { return "patchData" }()
        public static let testContainer_key = { return "patchDataTest" }()
        public static let estrogenEntityName = { return "Estrogen" }()
        public static let estrogenProps = { return ["date", "id", "siteNameBackUp"] }()
        public static let siteEntityName = { return "Site" }()
        public static let siteProps = { return ["order", "name"] }()
        public static let pillEntityName = { return "Pill" }()
        public static let pillProps = {
            return ["name", "timesaday", "time1", "time2",
                    "notify", "timesTakenToday", "lastTaken"]
        }()
    }
    
    // MARK: - User default keys
    
    public enum TodayKey: String {
        case nextEstroSiteName = "nextEstroSiteName"
        case nextEstroDate = "nextEstroDate"
        case nextPillToTake = "nextPillToTake"
        case nextPillTakeTime = "nextPillTakeTime"
    }
    
    public struct PillTypes {
        public static let defaultPills = { return ["T-Blocker", "Progesterone"] }()
        public static let extraPills = { return ["Estrogen", "Prolactin"] }()
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
