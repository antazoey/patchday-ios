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
        public static var done = { return NSLocalizedString("Done", comment: "Button title.  Could you keep it short?")
        }()
        public static var delete = { return NSLocalizedString("Delete", comment: "Button title.  Could you keep it short?")
        }()
        public static var take = { return NSLocalizedString("Take", comment: "Notification action. Used all over app, so please keep it short.")
        }()
        public static var taken = { return NSLocalizedString("Taken", comment: "Title for button, not too much room left for a really long word.") }()
        public static var save = { return NSLocalizedString("Save", comment: "Button title.  Room is fair.")
        }()
        public static var undo = { return NSLocalizedString("undo", comment: "Button title.  Could you keep it short?")
        }()
        public static var type = { return NSLocalizedString("Type", comment: "Button title.  Could you keep it short?")
        }()
        public static var select = { return NSLocalizedString("Select", comment: "Button title.  Could you keep it short?")
        }()
        public static var dismiss = { return NSLocalizedString("Dismiss", comment: "Button title.  Could you keep it short?")
        }()
        public static var accept = { return NSLocalizedString("Accept", comment: "Alert action. Room is not an issue.")
        }()
        public static var cont = { return NSLocalizedString("Continue", comment: "Alert action.  Room is not an issue")
        }()
        public static var decline = { return NSLocalizedString("Decline", comment: "Alert action.  Room is not an issue")
        }()
        public static var yes = { return NSLocalizedString("Yes", comment: "Alert action. Room is not an issue.")
        }()
        public static var no = { return NSLocalizedString("No", comment: "Alert action. Room is not an issue.")
        }()
        public static var edit = { return NSLocalizedString("Edit", comment: "Nav bar item title.  Could you keep it short?")
        }()
        public static var reset = { return NSLocalizedString("Reset", comment: "Nav bar item title. Could you keep it short?")
        }()
    }
    
    // MARK: - Days (Localizable)
    
    public struct DayStrings {
        public static var today = { return NSLocalizedString("Today", comment: "The word 'today' displayed on a button, don't worry about room.")
        }()
        public static var yesterday = { return NSLocalizedString("Yesterday", comment: "The word 'yesterday' displayed on a button, don't worry about room.")
        }()
        public static var tomorrow = { return NSLocalizedString("Tomorrow", comment: "The word 'tomorrow' displayed on a button, don't worry about room.")
        }()
    }
    
    // MARK: - Titles (Localizable)
    
    public struct TitleStrings {
        public static var pills = { return NSLocalizedString("Pills", comment: "Nav bar item left title.")
        }()
        public static var site = { return NSLocalizedString("Site", comment: "Title for view controller.")
        }()
        public static var sites = { return NSLocalizedString("Sites", comment: "Title of a view controller")
        }()
    }
    
    // MARK: - Placeholders (Localizable)
    
    public struct PlaceholderStrings {
        public static var nothing_yet = { return NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
        }()
        public static var dotdotdot = { return NSLocalizedString("...", tableName: nil, comment: "Instruction for empty patch")
        }()
        public static var unplaced = { return NSLocalizedString("unplaced", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
        }()
        public static var new_site = { return NSLocalizedString("New Site", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
        }()
        public static var new_pill = { return NSLocalizedString("New Pill", tableName: nil, comment: "Displayed under a button.  Medium room.")
        }()
    }
    
    // MARK: - VC Titles
    
    public struct VCTitles {
        public static var patches = { return NSLocalizedString("Patches", comment: "Title of a view controller. Keep it brief.") }()
        public static var injections = { return NSLocalizedString("Injections", comment: "Title of a view controller. Keep it brief.") }()
        public static var settings = { return NSLocalizedString("Settings", comment: "Title of a view controller. Keep it brief.") }()
        public static var pills = { return NSLocalizedString("Pills", comment: "Title of a view controller. Keep it brief.") }()
        public static var pill_edit = { return NSLocalizedString("Edit Pill", comment: "Title of a view controller. Keep it brief.") }()
        public static var pill_new = { return NSLocalizedString("New Pill", comment: "Title of a view controller. Keep it brief.") }()
        public static var sites = { return NSLocalizedString("Sites", comment: "Title of a view controller in the tab bar. Keep it brief.") }()
        public static var patch_sites = { return NSLocalizedString("Patch Sites", comment: "Title of a view controller. Keep it brief.") }()
        public static var injection_sites = { return NSLocalizedString("Injection Sites", comment: "Title of a view controller. Keep it brief.") }()
        public static var site_edit = { return NSLocalizedString("Edit Site", comment: "Title of a view controller. Keep it brief.") }()
        public static var site_new = { return NSLocalizedString("New Site", comment: "Title of a view controller. Keep it brief.") }()
        public static var estrogen = { return NSLocalizedString("Estrogen", comment: "Title of a view controller. Keep it brief.") }()
    }
    
    // MARK: - Coloned strings (Localizable)
    
    public struct ColonedStrings {
        public static var count = { return NSLocalizedString("Count:", comment: "Displayed on a label, plenty of room.") }()
        public static var time = { return NSLocalizedString("Time:", comment: "Displayed on a label, plenty of room.") }()
        public static var first_time = { return NSLocalizedString("First time:", comment: "Displayed on a label, plenty of room.") }()
        public static var expires = { return NSLocalizedString("Expires: ", tableName: nil, comment: "Label next to date. Easy on room.") }()
        public static var expired = { return NSLocalizedString("Expired: ", tableName: nil, comment: "Label next to dat. Easy on room.") }()
        public static var last_injected = { return NSLocalizedString("Injected: ", tableName: nil, comment: "Label next to dat. A little room to grow.") }()
        public static var next_due = { return NSLocalizedString("Next due: ", comment: "Label next to dat. A little room to grow.") }()
        public static var date_and_time_applied = { return NSLocalizedString("Date and time applied: ", comment: "Label next to dat. A little room to grow.") }()
        public static var date_and_time_injected = { return NSLocalizedString("Date and time injected: ", comment: "Label next to dat. A little room to grow.") }()
        public static var site = { return NSLocalizedString("Site: ", comment: "Label next to dat. Easy on room.") }()
        public static var last_site_injected = { return NSLocalizedString("Site injected: ", comment: "Label next to dat. A little room to grow") }()
    }
    
    // MARK: - Notification strings (Localizable)
    
    public struct NotificationStrings {

        public struct Titles {
            public static var patchExpired = { return NSLocalizedString("Time for your next patch", comment: "Title of notification.") }()
            public static var patchExpires = { return NSLocalizedString("Almost time for your next patch", comment: "Title of notification.") }()
            public static var injectionExpired = { return NSLocalizedString("Time for your next injection", comment: "Title of notification.") }()
            public static var injectionExpires = { return NSLocalizedString("Almost time for your next injection", comment: "Title of notification.") }()
            public static var takePill = { return NSLocalizedString("Time to take pill: ", comment: "Title of notification.") }()
            public static var overnight_patch = { return NSLocalizedString("Patch expired overnight.", comment: "Title of notification.") }()
            public static var overnight_injection = { return NSLocalizedString("Injection due overnight", comment: "Title of notification.") }()
        }
        
        public struct Bodies {
            public static var changePatchLocated = { return NSLocalizedString("Expired patch site: ", comment: "Notification telling you where and when to change your patch.") }()
            public static var injectionBody = { return NSLocalizedString("Your last injection site: ", comment: "Notification telling you where and when to inject next medication.") }()
            
            public static var siteToExpiredPatchMessage: [String : String] = ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: "Notification telling you where and when to change your patch."),"Left Abdomen" : NSLocalizedString("Change patch on your 'Left Abdomen' ", comment: "Notification telling you where and when to change your patch."),"Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: "Notification telling you where and when to change your patch."), "Left Glute" : NSLocalizedString("Change patch on your 'Left Glute' ", comment: "Notification telling you where and when to change a transdermal patch.")]
            
            public static var siteForNextPatch = { return NSLocalizedString("Site for next patch: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            }()
            
            public static var siteForNextInjection = { return NSLocalizedString("Site for next injection: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            }()
        }
        
        public struct actionMessages {
            public static var autofill = { return NSLocalizedString("Change to suggested site?", comment: "Notification action label.")
            }()
        }
  
    }
    
    // MARK: - Arrays (Localizable)
    
    public struct PickerData {
        
        public static var deliveryMethods: [String] = { return  [NSLocalizedString("Patches", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Injection", tableName: nil, comment: "Displayed on a button and in a picker.")]
        }()
        
        public static var expirationIntervals: [String] = { return  [NSLocalizedString("Twice-a-week", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Once a week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("Every two weeks", comment: "Displayed on a button and in a picker.")]
        }()

        public static var counts: [String] = { return [NSLocalizedString("1", comment: "Displayed in a picker."), NSLocalizedString("2", comment: "Displayed in a picker."), NSLocalizedString("3", comment: "Displayed in a picker."), NSLocalizedString("4", comment: "Displayed in a picker.")]
        }()
        
        public static var pillCounts: [String] = { return [counts[0], counts[1]] }()
        
    }
    
    // MARK: - Site names (Localizable)
    
    public struct SiteNames {
        
        public static var patchSiteNames: [String] = { return [NSLocalizedString("Right Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
            
        }()
        
        public static var rightAbdomen = { return patchSiteNames[2] }()
        public static var leftAbdomen = { return patchSiteNames[3] }()
        public static var rightGlute = { return patchSiteNames[0] }()
        public static var leftGlute = { return patchSiteNames[1] }()

        public static var injectionSiteNames: [String] =  { return [NSLocalizedString("Right Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Delt", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Delt", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
        }()
        
        public static var rightQuad = { return injectionSiteNames[0] }()
        public static var leftQuad = { return injectionSiteNames[1] }()
        public static var rightDelt = { return injectionSiteNames[4] }()
        public static var leftDelt = { return injectionSiteNames[5] }()
        
    }
    
    // MARK: - Delivery methods
    
    public struct DeliveryMethods {
        public static var patch = { return NSLocalizedString("Patch", comment: "Name of a View Controller. Keep short.  Refers to a transdermal medicinal patches.") }()
        public static var patches = { return NSLocalizedString("Patches", comment: "Name of a View Controller. Keep short.  Refers to a transdermal medicinal patches.") }()
        public static var injection = { return NSLocalizedString("Injection", comment: "Name of a View Controller. Keep short.  Refers to a transdermal medicinal patches.") }()
    }
    
    // MARK: - Alerts (Localizable)
    
    public struct AlertStrings {
        
        public struct CoreDataAlert {
            public static var title = { return NSLocalizedString("Data Error", comment: "Title for alert.") }()
            public static var message = { return NSLocalizedString("PatchDay's storage is not working. You may report the problem to support@patchdayhrt.com if you'd like.", comment: "Message for alert.") }()
        }
        
        public struct LoseDataAlert {
            public static var title = { return NSLocalizedString("Warning", comment: "Title for alert.") }()
            public static var message = { return NSLocalizedString("This action will result in a loss of data.", comment: "Message for alert.") }()
        }
        
        public struct StartUp  {
            public static var title = { return NSLocalizedString("Setup / Disclaimer", comment: "Title for an alert.  Don't worry about room.") }()
            
            public static var message = { return NSLocalizedString("To begin using PatchDay, tap the Edit button in the top right and setup your schedule.\n\nUse this tool responsibly, and please follow medication instructions!\n\nGo to www.PatchDayHRT.com to learn more.", comment: "Message for alert.") }()
            
            public static var support = { return NSLocalizedString("Support page", comment: "Title for action in alert. don't worry about room.") }()
        }
        
        public struct AddSite {
            public static var title = { return NSLocalizedString("Add new site name to sites list?", comment: "Title for an alert. Don't worry about room. It means to add a new name of a site on the body into a list.") }()
            
            public static var addActionTitle = { return NSLocalizedString("Yes, add it!", comment: "Title for action in an alert.  Able to grow.") }()
            
            public static var declineActionTitle = {return NSLocalizedString("No, that's okay.", comment: "Title for action in an alert.  Able to grow.") }()
        
        }
    
    }
    
    // Non-Localizable
    
    // MARK: - Core data keys
    
    public struct CoreDataKeys {
        public static var persistantContainer_key = { return "patchData" }()
        public static var estroEntityName = { return "Estrogen" }()
        public static var siteEntityName = { return "Site" }()
        public static var estroPropertyNames = { return ["date", "id"] }
        public static var sitePropertyNames = { return ["order", "name"] }()
        public static var pillEntityName = { return "Pill" }()
        public static var pillPropertyNames = { return ["name", "timesaday", "time1", "time2", "notify", "timesTakenToday", "lastTaken"] }()
    }
    
    // MARK: - User default keys
    public enum SettingsKey: String {
        case deliv = "delivMethod"
        case interval = "patchChangeInterval"
        case count = "numberOfPatches"
        case notif = "notification"
        case remind = "remindMeUpon"
        case setup = "mentioned"
        case site_index = "site_i"
        case needs_migrate = "nmig"
    }
    
    public enum TodayKey: String {
        case nextEstroSiteName = "nextEstroSiteName"
        case nextEstroDate = "nextEstroDate"
        case nextPillToTake = "nextPillToTake"
        case nextPillTakeTime = "nextPillTakeTime"
    }
    
    public struct PillTypes {
        public static var defaultPills = { return ["T-Blocker", "Progesterone"] }()
        public static var extraPills = { return ["Estrogen", "Prolactin"] }()
    }
    
    // MARK: - Color keys

    public enum ColorKeys: String {
        case offWhite = "offWhite"
        case lightBlue = "lightBlue"
        case gray = "cuteGray"
        case lightGray = "pdLighterCuteGray"
    }
    
}
