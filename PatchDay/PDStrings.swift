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
        static var done: String = NSLocalizedString("Done", comment: "Button title.  Could you keep it short?")
        static var delete: String = NSLocalizedString("Delete", comment: "Button title.  Could you keep it short?")
        static var edit: String = NSLocalizedString("Edit", comment: "Nav bar item title.  Could you keep it short?")
        static var take: String = NSLocalizedString("Take", comment: "Displayed in a notification action for taking a pill.")
        static var save: String = NSLocalizedString("Save", comment: "Room is fair.")
        static var undo: String = NSLocalizedString("undo", comment: "Button title.  Could you keep it short?")
        static var type: String = NSLocalizedString("Type", comment: "Button title.  Could you keep it short?")
        static var select: String = NSLocalizedString("Select", comment: "Button title.  Could you keep it short?")
        static var dismiss: String = NSLocalizedString("Dismiss", comment: "Button title.  Could you keep it short?")
        static var accept: String = NSLocalizedString("Accept", comment: "Alert action. Room is not an issue.")
        static var continue_: String = NSLocalizedString("Continue", comment: "Alert action.  Room is not an issue")
        static var decline: String = NSLocalizedString("Decline", comment: "Alert action.  Room is not an issue")
    }
    
    // MARK: - Days (Localizable)
    
    internal struct dayStrings {
        static var today: String = NSLocalizedString("Today", comment: "The word 'today' displayed on a button, don't worry about room.")
        static var yesterday: String = NSLocalizedString("Yesterday", comment: "The word 'yesterday' displayed on a button, don't worry about room.")
        static var tomorrow: String = NSLocalizedString("Tomorrow", comment: "The word 'tomorrow' displayed on a button, don't worry about room.")
    }
    
    // MARK: - Titles (Localizable)
    
    internal struct titleStrings {
        static var pills: String = NSLocalizedString("Pills", comment: "Nav bar item left title.")
        static var site: String = NSLocalizedString("Site", comment: "Title for view controller.")
        static var sites: String = NSLocalizedString("Sites", comment: "Title of a view controller")
    }
    
    // MARK: - Placeholders (Localizable)
    
    internal struct placeholderStrings {
        static var nothing_yet: String = NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
        static var dotdotdot: String = NSLocalizedString("...", tableName: nil, comment: "Instruction for empty patch")
        static var unplaced: String = NSLocalizedString("unplaced", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
    }
    
    // MARK: - Coloned strings (Localizable)
    
    internal struct colonedStrings {
        static var count: String = NSLocalizedString("Count:", comment: "Displayed on a label, plenty of room.")
        static var time: String = NSLocalizedString("Time:", comment: "Displayed on a label, plenty of room.")
        static var first_time: String = NSLocalizedString("First time:", comment: "for letting know the time when medication is taken")
        static var expires: String = NSLocalizedString("Expires: ", tableName: nil, comment: "label next to date.")
        static var expired: String = NSLocalizedString("Expired: ", tableName: nil, comment: "label next to dat.")
    }
    
    // MARK: - Fractions (Localizable)
    
    internal struct fractionStrings {
        private static var fractionArray: [String] = [NSLocalizedString("0/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("0/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("2/2", comment: "Fration, displayed in a button that takes half the screen width")]
        static var zeroOutOfOne = fractionArray[0]
        static var zeroOutOfTwo = fractionArray[1]
        static var oneOutOfOne = fractionArray[2]
        static var oneOutOfTwo = fractionArray[3]
        static var twoOutOfTwo = fractionArray[4]
    }
    
    // MARK: - Notification strings (Localizable)
    
    internal struct notificationStrings {

        struct titles {
            static var patchExpired: String = NSLocalizedString("Time for your next patch", comment: "Title of notification.")
            static var patchExpires: String = NSLocalizedString("Almost time for your next patch", comment: "Title of notification.")
            static var injectionExpired: String = NSLocalizedString("Time for your next injection", comment: "Title of notification.")
            static var injectionExpires: String = NSLocalizedString("Almost time for your next injection", comment: "Title of notification.")
            static var takeTB: String = NSLocalizedString("T-Block Time", comment: "A title for a notifiction.")
            static var takePG: String = NSLocalizedString("Take Progesterone", comment: "Title for a notification")
        }
        
        struct messages {
            static var siteToExpiredMessage: [String : String] = ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: "notification telling you where and when to change your patch."),"Left Abdomen" : NSLocalizedString("Change patch on your 'Left Abdomen' ", comment: "notification telling you where and when to change your patch."),"Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: "notification telling you where and when to change your patch."), "Left Glute" : NSLocalizedString("Change patch on your 'Left Glute'", comment: "notification telling you where and when to change your patch.")]
            
            static var siteForNextPatch: String = NSLocalizedString("Site for next patch: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            
            static var siteForNextInjection: String = NSLocalizedString("Site for next injection: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            
            static var takeTB: String = NSLocalizedString("It is time to take your testosterone blocker.", comment: "A message of a notification.")
            
            static var takePG: String = NSLocalizedString("It is take time to take your progesterone.", comment: "A message of a notificaiton")
            
        }
        
        struct actionMessages {
            static var autofill: String = NSLocalizedString("Change to suggested site?", comment: "Notification action label.")
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
            static var message: String = NSLocalizedString("PatchDay's storage is not working. You may report the problem to patchday@juliyasmith.com if you'd like.", comment: "Message for alert.")
        }
        
        struct loseDataAlert {
            static var title: String = NSLocalizedString("Warning", comment: "Title for alert.")
            static var message: String = NSLocalizedString("This action will result in a loss of data.", comment: "Message for alert.")
        }
        
        struct startUp  {
            static var title: String = NSLocalizedString("Setup / Disclaimer", comment: "Title for an alert.  Don't worry about room.")
            
            static var message: String = NSLocalizedString("To use PatchDay, go to the settings and set your delivery method (injections or patches), the time interval between doses, and the number of patches if applicable.\n\nUse this tool responsibly, and please follow medication instructions!\n\nGo to www.juliyasmith.com/patchday.html to learn more about how to use PatchDay as your HRT schedule app.", comment: "Message for alert.")
            
            static var support: String = NSLocalizedString("Support page", comment: "Title for action in alert. don't worry about room.")
        }
    }
    
    /**********************************
        NON-LOCALIZABLE
     **********************************/
    
    // MARK: - Core data keys
    
    internal struct coreDataKeys {
        static var persistantContainer_key: String = { return "patchData" }()
        static var estroEntityName: String = { return "Patch" }()
        static var estroEntityNames: [String] = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
        static var locEntityName: String = { return "Site" }()
        static var estroPropertyNames: [String] = { return ["datePlaced","location"] }()
        static var locPropertyNames: [String] = { return ["order", "name"] }()
    }
    
    // MARK: - User default keys

    internal struct userDefaultKeys {
        private static var defaultKeys: [String] = { return ["delivMethod", "patchChangeInterval", "numberOfPatches", "notification", "remindMeUpon", "mentioned", "i_tb", "i_pg", "tb_time", "pg_time", "tb_time2", "pg_time2", "tb_daily", "pg_daily", "tb_stamp", "pg_stamp",  "rTB", "rPG"] }()
        static var deliv: String = defaultKeys[0]
        static var interval: String = defaultKeys[1]
        static var count: String = defaultKeys[2]
        static var notif: String = defaultKeys[3]
        static var remind: String = defaultKeys[4]
        static var setup: String = defaultKeys[5]
        static var includeTB: String = defaultKeys[6]
        static var includePG: String = defaultKeys[7]
        static var tbTime1: String = defaultKeys[8]
        static var pgTime1: String = defaultKeys[9]
        static var tbTime2: String = defaultKeys[10]
        static var pgTime2: String = defaultKeys[11]
        static var tbDaily: String = defaultKeys[12]
        static var pgDaily: String = defaultKeys[13]
        static var tbStamp: String = defaultKeys[14]
        static var pgStamp: String = defaultKeys[15]
        static var remindTB: String = defaultKeys[16]
        static var remindPG: String = defaultKeys[17]
        
    }
    
    // MARK: - Color keys

    struct colorKeys {
        private static var colorKeys: [String] = { return ["offWhite","lightBlue","cuteGray","pdLighterCuteGray"] }()
        static var offWhite: String = colorKeys[0]
        static var lightBlue: String = colorKeys[1]
        static var gray = colorKeys[2]
        static var lightGray = colorKeys[3]
    }
    
    // MARK: - Notification keys
    
    struct  notificationIDs {
        static var expiredIDs: [String] = ["CHANGEPATCH1", "CHANGEPATCH2", "CHANGEPATCH3", "CHANGEPATCH4"]
        static var pillIDs: [String] = ["TBPILL","PGPILL"]
    }
    
    // MARK: - UI keys
    
    struct ui_ids {
        static var scheduleButtonIDs: [String] = { return ["patch1", "patch2", "patch3", "patch4"] }()
    }
    
}
