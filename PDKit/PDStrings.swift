//
//  PDStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDStrings {
    
    /**********************************
        LOCALIZABLE
    **********************************/
    
    // MARK: - Actions (Localizable)
    
    public struct actionStrings {
        public static var done = { return NSLocalizedString("Done", comment: "Button title.  Could you keep it short?")
        }()
        public static var delete = { return NSLocalizedString("Delete", comment: "Button title.  Could you keep it short?")
        }()
        public static var take = { return NSLocalizedString("Take", comment: "Notification action. Plenty of room.")
        }()
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
    
    public struct dayStrings {
        public static var today = { return NSLocalizedString("Today", comment: "The word 'today' displayed on a button, don't worry about room.")
        }()
        public static var yesterday = { return NSLocalizedString("Yesterday", comment: "The word 'yesterday' displayed on a button, don't worry about room.")
        }()
        public static var tomorrow = { return NSLocalizedString("Tomorrow", comment: "The word 'tomorrow' displayed on a button, don't worry about room.")
        }()
    }
    
    // MARK: - Titles (Localizable)
    
    public struct titleStrings {
        public static var pills = { return NSLocalizedString("Pills", comment: "Nav bar item left title.")
        }()
        public static var site = { return NSLocalizedString("Site", comment: "Title for view controller.")
        }()
        public static var sites = { return NSLocalizedString("Sites", comment: "Title of a view controller")
        }()
    }
    
    // MARK: - Placeholders (Localizable)
    
    public struct placeholderStrings {
        public static var nothing_yet = { return NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
        }()
        public static var dotdotdot = { return NSLocalizedString("...", tableName: nil, comment: "Instruction for empty patch")
        }()
        public static var unplaced = { return NSLocalizedString("unplaced", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
        }()
        public static var new_site = { return NSLocalizedString("New Site", tableName: nil, comment: "Probably won't be seen by users, so don't worry too much.")
        }()
    }
    
    // MARK: - Coloned strings (Localizable)
    
    public struct colonedStrings {
        public static var count = NSLocalizedString("Count:", comment: "Displayed on a label, plenty of room.")
        public static var time = NSLocalizedString("Time:", comment: "Displayed on a label, plenty of room.")
        public static var first_time = NSLocalizedString("First time:", comment: "for letting know the time when medication is taken")
        public static var expires = NSLocalizedString("Expires: ", tableName: nil, comment: "label next to date.")
        public static var expired = NSLocalizedString("Expired: ", tableName: nil, comment: "label next to dat.")
    }
    
    // MARK: - Fractions (Localizable)
    
    public struct fractionStrings {
        private static var fractionArray = [NSLocalizedString("0/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("0/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/1", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("1/2", comment: "Fration, displayed in a button that takes half the screen width"), NSLocalizedString("2/2", comment: "Fration, displayed in a button that takes half the screen width")]
        public static var zeroOutOfOne = fractionArray[0]
        public static var zeroOutOfTwo = fractionArray[1]
        public static var oneOutOfOne = fractionArray[2]
        public static var oneOutOfTwo = fractionArray[3]
        public static var twoOutOfTwo = fractionArray[4]
    }
    
    // MARK: - Notification strings (Localizable)
    
    public struct notificationStrings {

        public struct titles {
            public static var patchExpired = NSLocalizedString("Time for your next patch", comment: "Title of notification.")
            public static var patchExpires = NSLocalizedString("Almost time for your next patch", comment: "Title of notification.")
            public static var injectionExpired = NSLocalizedString("Time for your next injection", comment: "Title of notification.")
            public static var injectionExpires = NSLocalizedString("Almost time for your next injection", comment: "Title of notification.")
            public static var takeTB = NSLocalizedString("T-Block Time", comment: "A title for a notifiction.")
            public static var takePG = NSLocalizedString("Take Progesterone", comment: "Title for a notification")
        }
        
        public struct messages {
            public static var siteToExpiredMessage: [String : String] = ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: "notification telling you where and when to change your patch."),"Left Abdomen" : NSLocalizedString("Change patch on your 'Left Abdomen' ", comment: "notification telling you where and when to change your patch."),"Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: "notification telling you where and when to change your patch."), "Left Glute" : NSLocalizedString("Change patch on your 'Left Glute'", comment: "notification telling you where and when to change your patch.")]
            
            public static var siteForNextPatch = { return NSLocalizedString("Site for next patch: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            }()
            
            public static var siteForNextInjection = { return NSLocalizedString("Site for next injection: ", comment: "The name of a site on the body follows this message in a notification. Don't worry about room.")
            }()
            
            public static var takeTB = { return NSLocalizedString("It is time to take your testosterone blocker.", comment: "A message of a notification.")
            }()
            
            public static var takePG = { return NSLocalizedString("It is take time to take your progesterone.", comment: "A message of a notificaiton")
            }()
        }
        
        public struct actionMessages {
            public static var autofill = { return NSLocalizedString("Change to suggested site?", comment: "Notification action label.")
            }()
        }
  
    }
    
    // MARK: - Arrays (Localizable)
    
    public struct pickerData {
        
        public static var deliveryMethods: [String] = { return  [NSLocalizedString("Patches", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Injection", tableName: nil, comment: "Displayed on a button and in a picker.")]
        }()
        
        public static var expirationIntervals: [String] = { return  [NSLocalizedString("Twice-a-week", tableName: nil, comment: "Displayed on a button and in a picker."), NSLocalizedString("Once a week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("Every two weeks", comment: "Displayed on a button and in a picker.")]
        }()

        public static var counts: [String] = { return [NSLocalizedString("1", comment: "Displayed in a picker."), NSLocalizedString("2", comment: "Displayed in a picker."), NSLocalizedString("3", comment: "Displayed in a picker."), NSLocalizedString("4", comment: "Displayed in a picker.")]
        }()
        
        public static var pillCounts: [String] = { return [counts[0], counts[1]] }()
        
        public static var notificationTimes: [String] = { return [NSLocalizedString("0 minutes", comment: "Displayed in a picker."), NSLocalizedString("30 minutes", comment: "Displayed in a picker."), NSLocalizedString("60 minutes", comment: "Displayed in a picker."), NSLocalizedString("120 minutes", comment: "Displayed in a picker.")]
        }()
        
    }
    
    // MARK: - Site names (Localizable)
    
    public struct siteNames {
        
        public static var patchSiteNames: [String] = { return [NSLocalizedString("Right Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Abdomen", tableName: nil, comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
            
        }()
        
        public static var rightAbdomen = { return patchSiteNames[2] }()
        public static var leftAbdomen = { return patchSiteNames[3] }()
        public static var rightGlute = { return patchSiteNames[0] }()
        public static var leftGlute = { return patchSiteNames[1] }()

        public static var injectionSiteNames: [String] =  { return [NSLocalizedString("Right Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Quad", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Right Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?"), NSLocalizedString("Left Glute", comment: "Displayed all over the app.  Could you abbreviate if it is more than 2x as long?")]
        }()
        
        public static var rightQuad = { return injectionSiteNames[0] }()
        public static var leftQuad = { return injectionSiteNames[1] }()
        
    }
    
    // MARK: - Alerts (Localizable)
    
    public struct alertStrings {
        
        public struct coreDataAlert {
            public static var title = { return NSLocalizedString("Data Error", comment: "Title for alert.") }()
            public static var message = { return NSLocalizedString("PatchDay's storage is not working. You may report the problem to patchday@juliyasmith.com if you'd like.", comment: "Message for alert.") }()
        }
        
        public struct loseDataAlert {
            public static var title = { return NSLocalizedString("Warning", comment: "Title for alert.") }()
            public static var message = { return NSLocalizedString("This action will result in a loss of data.", comment: "Message for alert.") }()
        }
        
        public struct startUp  {
            public static var title = { return NSLocalizedString("Setup / Disclaimer", comment: "Title for an alert.  Don't worry about room.") }()
            
            public static var message = { return NSLocalizedString("To use PatchDay, go to the settings and set your delivery method (injections or patches), the time interval between doses, and the number of patches if applicable.\n\nUse this tool responsibly, and please follow medication instructions!\n\nGo to www.juliyasmith.com/patchday.html to learn more about how to use PatchDay as your HRT schedule app.", comment: "Message for alert.") }()
            
            public static var support = { return NSLocalizedString("Support page", comment: "Title for action in alert. don't worry about room.") }()
        }
        
        public struct addSite {
            public static var title = { return NSLocalizedString("Add new site name to sites list?", comment: "Title for an alert. Don't worry about room. It means to add a new name of a site on the body into a list.") }()
        }
    }
    
    /**********************************
        NON-LOCALIZABLE
     **********************************/
    
    // MARK: - Core data keys
    
    public struct coreDataKeys {
        public static var persistantContainer_key = { return "patchData" }()
        public static var estroEntityName = { return "Patch" }()
        public static var estroEntityNames = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
        public static var locEntityName = { return "Site" }()
        public static var estroPropertyNames = { return ["datePlaced","location"] }()
        public static var locPropertyNames = { return ["order", "name"] }()
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
    
    public struct TodayKeys {
        public static var tbTaken = { return "tb_taken" }()
    }
    
    // MARK: - Color keys

    public enum ColorKeys: String {
        case offWhite = "offWhite"
        case lightBlue = "lightBlue"
        case gray = "cuteGray"
        case lightGray = "pdLighterCuteGray"
    }
    
    // MARK: - Notification keys
    
    public struct notificationIDs {
        public static var expiredIDs = {return ["CHANGEPATCH1", "CHANGEPATCH2", "CHANGEPATCH3", "CHANGEPATCH4"] }()
        public static var pillIDs = {return ["TBPILL","PGPILL"] }()
    }
    
    // MARK: - UI keys
    
    public struct ui_ids {
        public static var estrogenButtonIDs = { return ["patch1", "patch2", "patch3", "patch4"] }()
    }
    
}
