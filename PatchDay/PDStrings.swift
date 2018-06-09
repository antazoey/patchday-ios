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
    
    // MARK: - Localizable
    
    internal static var take: String = NSLocalizedString("Take", comment: "Displayed in a notification action for taking a pill")
    
    internal static var today_title: String = NSLocalizedString("Today", comment: "The word 'today' displayed on a button, don't worry about room.")
    
    internal static var yesterday_title: String = NSLocalizedString("Yesterday", comment: "The word 'yesterday' displayed on a button, don't worry about room.")
    
    internal static var tomorrow_title: String = NSLocalizedString("Tomorrow", comment: "The word 'tomorrow' displayed on a button, don't worry about room.")
    
    internal static var count_label: String = NSLocalizedString("Count:", comment: "displaying on label, for choosing number of estrogen deliveries")
    
    internal static var beforeExpiration_label: String = NSLocalizedString("Before expiration:", comment: "for indicating whether the user wants to recieve a notification before an expiration")
    
    internal static var nothing_yet_placeholder: String = NSLocalizedString("Nothing yet", comment: "A placeholder where a date will go")
    
    internal static var emptyDate_placeholder: String = NSLocalizedString("Choose date.", comment: "placeholder in date text field")
    
    internal static var pills: String = NSLocalizedString("Pills", comment: "title of a nav bar button item for navigating to a pill schedule view")
    
    internal static var save: String = NSLocalizedString("Save", comment: "for closing a picker view")
    
    internal static var undo: String = NSLocalizedString("undo", comment: "for undoing an action, placed on button")
    
    internal static var due: String = NSLocalizedString("due", comment: "the word due, just in text, indicating something is due")
    
    internal static var time: String = NSLocalizedString("Time:", comment: "for letting know the time when medication is taken")
    
    internal static var tb_disabled: String = NSLocalizedString("T-Blocker (disabled)", comment: "for letting know the t-blocker functionality is disabled, in a title")
    
    internal static var pg_disabled: String = NSLocalizedString("Progesterone (disabled)", comment: "for letting know the progesterone functionality is disabled, in a title")
    
    internal static var timeBeforeExp: String = NSLocalizedString("Time before:", comment: "for indicating the amount of time to recieve a reminder notification before medication expires")
    
    internal static var first_time: String = NSLocalizedString("First time:", comment: "for letting know the time when medication is taken")
    
    internal static var hasNoDate: String = NSLocalizedString("Patch has no date!", comment: "for when there is no date associated with the patch")
    
    internal static var patchExpired_title: String = NSLocalizedString("Time for your next patch", comment: "title of notification about the need to take a medicaiton")
    
    internal static var patchExpiresSoon_title: String = NSLocalizedString("Almost time for your next patch", comment: "title of notification about an need to take a medication")
    
    internal static var injectionExpired_title: String = NSLocalizedString("Time for your next injection", comment: "title of notification about the need to take a medication")
    
    internal static var injectionExpiresSoon_title: String = NSLocalizedString("Almost time for your next injection", comment: "title of notification about an need to take a medication")
    
    internal static var auto_string: String = NSLocalizedString("Autofill", comment: "Label for autofilling properties")
    
    internal static var autoChange_string: String = NSLocalizedString("Change to suggested location?", comment: "Label for auto-changing properties in a notification")
    
    internal static var emptyLocationInstruction: String = NSLocalizedString("Type or choose location.", comment: "placeholder in location text field when")
    
    internal static var deliveryMethods: [String] = [NSLocalizedString("Patches", tableName: nil, comment: "Medical patches, displayed on a button."), NSLocalizedString("Injection", tableName: nil, comment: "Medical injection, displayed on a button")]
    
    internal static var expirationIntervals: [String] = [NSLocalizedString("One half-week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("One week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("Two weeks", comment: "Displayed in a picker.")]
    
    internal static var patchLocationNames: [String] = [NSLocalizedString("Right Glute", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Glute", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Right Abdomen", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Abdomen", tableName: nil, comment: "location on body for where to place patch")]
    
    internal static var injectionLocationNames: [String] = [NSLocalizedString("Right Quad", comment: "Part of the body (leg)"), NSLocalizedString("Left Quad", comment: "Part of the body (leg)")]
    
    internal static var patchDetailsInstruction: String = NSLocalizedString("...", tableName: nil, comment: "instruction for empty patch")
    
    internal static var patchExpires_string: String = NSLocalizedString("Expires: ", tableName: nil, comment: "label next to date")
    
    internal static var patchExpired_string: String = NSLocalizedString("Expired: ", tableName: nil, comment: "label next to date")
    
    internal static var pill_taken: String = NSLocalizedString("✔️", tableName: nil, comment: "letting you know a pill was taken, displayed on a button.")
    
    // notifications
    
    internal static var expiredPatchNotificationIntros: [String : String] = ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: "notification telling you where and when to change your patch."),"Left Abdomen" : NSLocalizedString("Change patch on your 'Left Abdomen' ", comment: "notification telling you where and when to change your patch."),"Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: "notification telling you where and when to change your patch."),"Left Glute" : NSLocalizedString("Change patch on your 'Left Glute' ", comment: "notification telling you where and when to change your patch.")]
    
    internal static var expiredPatchNotificationIntroForCustom: String = NSLocalizedString("Change patch ", comment: "notification tite for a custom located patch")
    
    internal static var expiredPatchNotificationIntroForCustom_at: String = NSLocalizedString("at: ", comment: " for displaying the date of the expired patch for a custom located notification, occruing directly after expiredPatchNotificationIntroForCustom message")
    
    internal static var notificationSuggestedLocation: String = NSLocalizedString("Place new patch here: ", comment: "followed by a suggest location; second line in the notification if and only if the user enabled Suggestion Location Functionality on the SettingsVC")
    
    internal static var notificationExpiredPatchWithoutLocation: String = NSLocalizedString("Change a patch ", comment: "notification when there is no location pressent, this really should never happen")
    
    internal static var takeTBNotificationTitle: String = NSLocalizedString("Take T-Blocker", comment: "A title for a notifiction, T-Blocker refers to Testosterone Blocker, a type of drug")
    
    internal static var takeTBNotificationMessage: String = NSLocalizedString("It is time to take your testosterone blocker.", comment: "A message of a notification")
    
    internal static var takePGNotificationTitle: String = NSLocalizedString("Take Progesterone", comment: "Title for a notification")
    
    internal static var takePGNotificationMessage: String = NSLocalizedString("It is take time to take your progesterone.", comment: "A message of a notificaiton")
    
    // MARK: - core data alert
    
    internal static var coreDataSaveAlertTitle: String = NSLocalizedString("Save ERROR", comment: "this is a title to an alert displayed if patch data is not saved for some reason.")
    
    internal static var coreDataSaveAlertMessage: String = NSLocalizedString("There was a problem saving your patch data!", comment: "this is a message to an alert displayed if patch data is not saved for some reason.")
    
    internal static var coreDataAlertTitle: String = NSLocalizedString("Core Data ERROR", comment: "this is a title to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    
    internal static var coreDataAlertMessage: String = NSLocalizedString("There is a problem with managed object in the persistent store", comment: "this is a message to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    internal static var dismiss_string: String = NSLocalizedString("Dismiss", comment: "The word displayed on a button for dismissing an error message")
    
    internal static var accept_string: String = NSLocalizedString("Accept", comment: "an accept button title displayed on the 'changing number of patches' alert")
    
    internal static var yes_string: String = NSLocalizedString("Yes", comment: "a yes button for an alert")
    
    internal static var no_string: String = NSLocalizedString("No", comment: "a no button for an alert")
    
    // MARK: - change number of MOs
    
    internal static var warning: String = NSLocalizedString("Warning", comment: "title for alert")
    
    internal static var losingDataMsg: String = NSLocalizedString("This action will result in a loss of data.", comment: "title for alert for changing number of patches (could result in loss of data)")
    
    internal static var continue_string: String = NSLocalizedString("Continue", comment: "a button for proceeding during an alert")
    
    internal static var cancel_string: String = NSLocalizedString("Decline", comment: "a cancel button title displayed on the 'changing number of patches' alert")
    
    // MARK: - use notifications alert
    
    internal static var maybeYouShouldUseNotificationsAlertTitle: String = NSLocalizedString("Try Notifications?", comment: "a title for a popup alert asking the user to try the app with notifications turned on")
    
    internal static var maybeYouShouldUseNotificationsAlertMessage: String = NSLocalizedString("With notifications turned on, PatchDay is able to let you know when your patches expire. Turn it on now?", comment: "a message for a popup alert asking the user to try the app with notifications turned on")
    
    // MARK: - suggest location alert
    
    internal static var suggestLocationAlertTitle: String = NSLocalizedString("Suggested Locations", comment: "a descriptive alert title that appears when enabling or disabling the SLF bool from the Settings")
    
    internal static var suggestLocationAlertMessage: String = NSLocalizedString("When 'Autofill location' is turned on, the 'Autofill' button from the Details view will give you an optimal location!", comment: "a descriptive alert message that appears when enabling or disabling the Autofill Location Functionality bool from the Settings")
    
    // MARK: - disclaimer
    
    internal static var disclaimerAlertTitle: String = NSLocalizedString("Setup / Disclaimer", comment: "Title for an alert that shows up the first time the app launches.")
    
    internal static var disclaimerAlertMessage: String = NSLocalizedString("To use PatchDay, go to the settings and set your delivery method (injections or patches), the time interval between doses, and the number of patches if applicable.\n\nUse this tool responsibly, and please follow medication instructions!\n\nGo to www.juliyasmith.com/patchday.html to learn more about how to use PatchDay as your HRT schedule app.", comment: "Message for an alert that shows up the first time the app launches.")
    
    internal static var goToSupport: String = NSLocalizedString("Support page", comment: "")
    
    // MARK: - numerical
    
    internal static var counts: [String] = { return ["1", "2", "3", "4"] }()
    
    internal static var dailyCounts: [String] = { return ["1", "2"] }()
    
    internal static var notificationSettings: [String] = { return ["0 minutes", "30 minutes", "60 minutes", "120 minutes"] }()
    
    // MARK: - general
    
    internal static var unplaced_string: String = { return "unplaced"}()
    
    internal static var entityName: String = { return "Patch" }()
    
    // MARK: - ScheduleController
    
    internal static var moPropertyNames: [String] = {return ["datePlaced","location"] }()
    
    internal static var entityNames: [String] = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
    
    internal static var persistantContainer_key: String = { return "patchData" }()
    
    // MARK: - UserDefaultsController
    
    internal static var defaultKeys: [String] = { return ["patchChangeInterval", "numberOfPatches", "autoChooseLocation", "notification", "remindMe", "mentioned", "i_tb", "i_pg", "tb_time", "pg_time", "tb_daily", "pg_daily", "tb_time2", "pg_time2", "remindMeUpon", "tb_stamp", "pg_stamp", "tb_next", "pg_next", "rTB", "rPG", "delivMethod"] }()
    
    internal static func interval_key() -> String {
        return defaultKeys[0]
    }
    
    internal static func count_key() -> String {
        return defaultKeys[1]
    }
    
    internal static func slf_key() -> String {
        return defaultKeys[2]
    }
    
    internal static func notif_key() -> String {
        return defaultKeys[3]
    }
    
    internal static func rMeBefore_key() -> String {
        return defaultKeys[4]
    }
    
    internal static func mentionedDisc_key() -> String {
        return defaultKeys[5]
    }
    
    internal static func includeTB_key() -> String {
        return defaultKeys[6]
    }
    
    internal static func includePG_key() -> String {
        return defaultKeys[7]
    }
    
    internal static func tbTime_key() -> String {
        return defaultKeys[8]
    }
    
    internal static func pgTime_key() -> String {
        return defaultKeys[9]
    }
    
    internal static func tb_daily_key() -> String {
        return defaultKeys[10]
    }
    
    internal static func pg_daily_key() -> String {
        return defaultKeys[11]
    }
    
    internal static func tb2Time_key() -> String {
        return defaultKeys[12]
    }
    
    internal static func pg2Time_key() -> String {
        return defaultKeys[13]
    }
    
    internal static func rMeUpon_key() -> String {
        return defaultKeys[14]
    }
    
    internal static func tbStamp_key() -> String {
        return defaultKeys[15]
    }
    
    internal static func pgStamp_key() -> String {
        return defaultKeys[16]
    }
    
    internal static func tbNext_key() -> String {
        return defaultKeys[17]
    }
    
    internal static func pgNext_key() -> String {
        return defaultKeys[18]
    }
    
    internal static func rTB_key() -> String {
        return defaultKeys[19]
    }
    
    internal static func rPG_key() -> String {
        return defaultKeys[20]
    }
    
    internal static func deliveryMethod_key() -> String {
        return defaultKeys[21]
    }
    
    // MARK: - Colors
    
    internal static var colorKeys: [String] = { return ["offWhite","lightBlue","cuteGray","lighterCuteGray"] }()
    
    internal static func offWhite() -> String {
        return colorKeys[0]
    }
    
    internal static func lightBlue() -> String {
        return colorKeys[1]
    }
    
    internal static func cuteGray() -> String {
        return colorKeys[2]
    }
    
    internal static func lighterCuteGray() -> String {
        return colorKeys[3]
    }
    
    // MARK: - getting location names
    
    internal static func rightButt() -> String {
        return patchLocationNames[0]
    }
    
    internal static func leftButt() -> String {
        return patchLocationNames[1]
    }
    
    internal static func rightStom() -> String {
        return patchLocationNames[2]
    }
    
    internal static func leftStom() -> String {
        return patchLocationNames[3]
    }
    
    internal static func rightQuad() -> String {
        return injectionLocationNames[0]
    }
    
    internal static func leftQuad() -> String {
        return injectionLocationNames[1]
    }
    
    // MARK: - notification related
    
    internal static var changeSoonIDs: [Int: String] = [0: "CHANGEPATCH1", 1: "CHANGEPATCH2", 2: "CHANGEPATCH3", 3: "CHANGEPATCH4"]
    
    internal static var pillIDs: [String] = ["TBPILL","PGPILL"]
    
    // MARK: - patch button id's
    internal static var scheduleButtonIDs: [String] = { return ["patch1", "patch2", "patch3", "patch4"] }()
    
    
}
