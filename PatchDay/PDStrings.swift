//
//  PDStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

// read-only

class PDStrings {
    
    /**********************************
        LOCALIZABLE
    **********************************/
    
    // MARK: - Actions (Localizable)
    
    internal struct actionStrings {
        static var done = NSLocalizedString("Done", comment: "Button title.  Could you keep it short?")
        static var delete = NSLocalizedString("Delete", comment: "Button title.  Could you keep it short?")
        static var take = NSLocalizedString("Take", comment: "Notification action. Plenty of room.")
        static var save = NSLocalizedString("Save", comment: "Button title.  Room is fair.")
        static var undo = NSLocalizedString("undo", comment: "Button title.  Could you keep it short?")
        static var type = NSLocalizedString("Type", comment: "Button title.  Could you keep it short?")
        static var select = NSLocalizedString("Select", comment: "Button title.  Could you keep it short?")
        static var dismiss = NSLocalizedString("Dismiss", comment: "Button title.  Could you keep it short?")
        static var accept = NSLocalizedString("Accept", comment: "Alert action. Room is not an issue.")
        static var cont = NSLocalizedString("Continue", comment: "Alert action.  Room is not an issue")
        static var decline = NSLocalizedString("Decline", comment: "Alert action.  Room is not an issue")
        static var yes = NSLocalizedString("Yes", comment: "Alert action. Room is not an issue.")
        static var no = NSLocalizedString("No", comment: "Alert action. Room is not an issue.")
        static var edit = NSLocalizedString("Edit", comment: "Nav bar item title.  Could you keep it short?")
        static var reset = NSLocalizedString("Reset", comment: "Nav bar item title. Could you keep it short?")
    }
    
    // MARK: - Days (Localizable)
    
    internal struct dayStrings {
        static var today = NSLocalizedString("Today", comment: "The word 'today' displayed on a button, don't worry about room.")
        static var yesterday = NSLocalizedString("Yesterday", comment: "The word 'yesterday' displayed on a button, don't worry about room.")
        static var tomorrow = NSLocalizedString("Tomorrow", comment: "The word 'tomorrow' displayed on a button, don't worry about room.")
    }
    
    // MARK: - Titles (Localizable)
    
    internal struct titleStrings {
        static var pills = NSLocalizedString("Pills", comment: "Nav bar item left title.")
        static var site = NSLocalizedString("Site", comment: "Title for view controller.")
        static var sites = NSLocalizedString("Sites", comment: "Title of a view controller")
    }
    
    // MARK: - Placeholders (Localizable)
    
    internal struct placeholderStrings {
        static var nothing_yet = NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
        static var dotdotdot = NSLocalizedString("...", tableName: nil, comment: "Instruction for empty patch")
        static var unplaced = NSLocalizedString("unplaced", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
        static var new_site = NSLocalizedString("New Site", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
    }
    
    // MARK: - Coloned strings (Localizable)
    
    internal struct colonedStrings {
        static var count = NSLocalizedString("Count:", comment: "Displayed on a label, plenty of room.")
        static var time = NSLocalizedString("Time:", comment: "Displayed on a label, plenty of room.")
        static var first_time = NSLocalizedString("First time:", comment: "for letting know the time when medication is taken")
        static var expires = NSLocalizedString("Expires: ", tableName: nil, comment: "label next to date.")
        static var expired = NSLocalizedString("Expired: ", tableName: nil, comment: "label next to dat.")
    }
    
    // MARK: - Fractions (Localizable)
    
    internal struct fractionStrings {
        private static var fractionArray = [NSLocalizedString("0/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("0/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("2/2", comment: "Fration, displayed in a button that takes half the screen width")]
        static var zeroOutOfOne = fractionArray[0]
        static var zeroOutOfTwo = fractionArray[1]
        static var oneOutOfOne = fractionArray[2]
        static var oneOutOfTwo = fractionArray[3]
        static var twoOutOfTwo = fractionArray[4]
    }
    
    // MARK: - Notification strings (Localizable)
    
    internal struct notificationStrings {

        struct titles {
            static var patchExpired = NSLocalizedString("Time for your next patch", comment: "Title of notification.")
            static var patchExpires = NSLocalizedString("Almost time for your next patch", comment: "Title of notification.")
            static var injectionExpired = NSLocalizedString("Time for your next injection", comment: "Title of notification.")
            static var injectionExpires = NSLocalizedString("Almost time for your next injection", comment: "Title of notification.")
            static var takeTB = NSLocalizedString("T-Block Time", comment: "A title for a notifiction.")
            static var takePG = NSLocalizedString("Take Progesterone", comment: "Title for a notification")
        }
        
        struct messages {
            static var siteToExpiredMessage: [String : String] = ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: "notification telling you where and when to change your patch."),"Left Abdomen" : NSLocalizedString("Change patch on your 'Left Abdomen' ", comment: "notification telling you where and when to change your patch."),"Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: "notification telling you where and when to change your patch."), "Left Glute" : NSLocalizedString("Change patch on your 'Left Glute'", comment: "notification telling you where and when to change your patch.")]
            
            static var siteForNextPatch = NSLocalizedString("Site for next patch: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            
            static var siteForNextInjection = NSLocalizedString("Site for next injection: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            
            static var takeTB = NSLocalizedString("It is time to take your testosterone blocker.", comment: "A message of a notification.")
            
            static var takePG = NSLocalizedString("It is take time to take your progesterone.", comment: "A message of a notificaiton")
            
        }
        
        struct actionMessages {
            static var autofill = NSLocalizedString("Change to suggested site?", comment: "Notification action label.")
        }
  
    }
    
    // MARK: - Arrays (Localizable)
    
    internal struct pickerData {
        
        static var deliveryMethods: [String] = [NSLocalizedString("Patches", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Injection", tableName: nil, comment: "Displayed on a button and in a picker.")]
        
        static var expirationIntervals: [String] = [NSLocalizedString("Twice-a-week", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Once a week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("Every two weeks", comment: "Displayed on a button and in a picker.")]

        static var counts: [String] = [NSLocalizedString("1", comment: "Displayed in a picker."), NSLocalizedString("2", comment: "Displayed in a picker."), NSLocalizedString("3", comment: "Displayed in a picker."), NSLocalizedString("4", comment: "Displayed in a picker.")]
        
        static var pillCounts: [String] = { return [counts[0], counts[1]] }()
        
        static var notificationTimes: [String] = [NSLocalizedString("0 minutes", comment: "Displayed in a picker."), NSLocalizedString("30 minutes", comment: "Displayed in a picker."), NSLocalizedString("60 minutes", comment: "Displayed in a picker."), NSLocalizedString("120 minutes", comment: "Displayed in a picker.")]
        
    }
    
    // MARK: - Site names (Localizable)
    
    internal struct siteNames {
        
        static var patchSiteNames: [String] = [NSLocalizedString("Right Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
        
        static var rightAbdomen = patchSiteNames[2]
        static var leftAbdomen = patchSiteNames[3]
        static var rightGlute = patchSiteNames[0]
        static var leftGlute = patchSiteNames[1]

        static var injectionSiteNames: [String] = [NSLocalizedString("Right Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
        
        static var rightQuad = injectionSiteNames[0]
        static var leftQuad = injectionSiteNames[1]
        
    }
    
    // MARK: - Alerts (Localizable)
    
    internal struct alertStrings {
        
        struct coreDataAlert {
            static var title = NSLocalizedString("Data Error", comment: "Title for alert.")
            static var message = NSLocalizedString("PatchDay's storage is not working. You may report the problem to patchday@juliyasmith.com if you'd like.", comment: "Message for alert.")
        }
        
        struct loseDataAlert {
            static var title = NSLocalizedString("Warning", comment: "Title for alert.")
            static var message = NSLocalizedString("This action will result in a loss of data.", comment: "Message for alert.")
        }
        
        struct startUp  {
            static var title = NSLocalizedString("Setup / Disclaimer", comment: "Title for an alert.  Don't worry about room.")
            
            static var message = NSLocalizedString("To use PatchDay, go to the settings and set your delivery method (injections or patches), the time interval between doses, and the number of patches if applicable.\n\nUse this tool responsibly, and please follow medication instructions!\n\nGo to www.juliyasmith.com/patchday.html to learn more about how to use PatchDay as your HRT schedule app.", comment: "Message for alert.")
            
            static var support = NSLocalizedString("Support page", comment: "Title for action in alert. don't worry about room.")
        }
        
        struct addSite {
            static var title = NSLocalizedString("Add new site name to sites list?", comment: "Title for an alert. Don't worry about room. It means to add a new name of a site on the body into a list.")
        }
    }
    
    /**********************************
        NON-LOCALIZABLE
     **********************************/
    
    // MARK: - Core data keys
    
    internal struct coreDataKeys {
        static var persistantContainer_key = { return "patchData" }()
        static var estroEntityName = { return "Patch" }()
        static var estroEntityNames = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
        static var locEntityName = { return "Site" }()
        static var estroPropertyNames = { return ["datePlaced","location"] }()
        static var locPropertyNames = { return ["order", "name"] }()
    }
    
    // MARK: - User default keys
    enum SettingsKey: String {
        case deliv = "delivMethod"
        case interval = "patchChangeInterval"
        case count = "numberOfPatches"
        case notif = "notification"
        case remind = "remindMeUpon"
        case setup = "mentioned"
        case site_index = "site_i"
        case includeTB = "i_tb"
        case includePG = "i_pg"
        case tbTime1 = "tb_time"
        case pgTime1 = "pg_time"
        case tbTime2 = "tb_time2"
        case pgTime2 = "pg_time2"
        case tbDaily = "tb_daily"
        case pgDaily = "pg_daily"
        case tbStamp = "tb_stamp"
        case pgStamp = "pg_stamp"
        case remindTB = "rTB"
        case remindPG = "rPG"
    }
    
    // MARK: - Color keys

    struct colorKeys {
        private static var colorKeys: [String] = { return ["offWhite","lightBlue","cuteGray","pdLighterCuteGray"] }()
        static var offWhite = colorKeys[0]
        static var lightBlue = colorKeys[1]
        static var gray = colorKeys[2]
        static var lightGray = colorKeys[3]
    }
    
    // MARK: - Notification keys
    
    struct  notificationIDs {
        static var expiredIDs = ["CHANGEPATCH1", "CHANGEPATCH2", "CHANGEPATCH3", "CHANGEPATCH4"]
        static var pillIDs = ["TBPILL","PGPILL"]
    }
    
    // MARK: - UI keys
    
    struct ui_ids {
        static var scheduleButtonIDs = { return ["patch1", "patch2", "patch3", "patch4"] }()
    }
    
}
