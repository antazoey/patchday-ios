//
//  PatchDayStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

// read-only
class PatchDayStrings {
    
    // MARK: - Localizable
    
    static var hasNoDate: String = { return NSLocalizedString("Patch has no date!", comment: "for when there is no date associated with the patch") }()
    
    static var addPatch_string: String = { return NSLocalizedString("Add Patch", comment: "Label for view when adding a new patch") }()
    
    static var changePatch_string: String = { return NSLocalizedString("Change Patch", comment: "Label for view when changing a patch") }()
    
    static var expiredPatch_string: String = { return NSLocalizedString("Expired Patch", comment: "Label for view when changing a patch") }()
    
    static var emptyDateInstruction: String = { return NSLocalizedString("choose ⇢", comment: "placeholder in date text field when it's a new patch") }()
    
    static var emptyLocationInstruction: String = { return NSLocalizedString("⌨ custom or choose ⇢", comment: "placeholder in location text field when it's a new patch") }()
    
    static var expirationIntervals: [String] = { return [NSLocalizedString("Half-Week", tableName: nil, comment: "SettingsViewController, it's an option for choosing which interval the patches expire. "), NSLocalizedString("Week", tableName: nil, comment: "SettingsViewController, it's an option for choosing which interval the patches expire. ")] }()
    
    static var patchCounts: [String] = { return [NSLocalizedString("1", tableName: nil, comment: "number of patches"),NSLocalizedString("2", tableName: nil, comment: "number of patches"),NSLocalizedString("3", tableName: nil, comment: "number of patches"),NSLocalizedString("4", tableName: nil, comment: "number of patches")] }()
    
    static var notificationSettings: [String] = { return [NSLocalizedString("30", tableName: nil, comment: "discussing when to receive a notification"), NSLocalizedString("60", tableName: nil, comment: "discussing when to receive a notification"),NSLocalizedString("120", tableName: nil, comment: "discussing when to receive a notification")] }()
    
    static var patchLocationNames: [String] = { return [NSLocalizedString("Right Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Right Stomach", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Stomach", tableName: nil, comment: "location on body for where to place patch")] }()
    
    static var addPatchInstruction: String = {return NSLocalizedString("Edit when and where the patch was placed", tableName: nil, comment: "instruction for empty patch") }()
    
    static var patchExpires_string: String = { return NSLocalizedString("Patch Expires: ", tableName: nil, comment: "instruction for patch details") }()
    
    static var patchExpired_string: String = { return NSLocalizedString("Patch Expires: ", tableName: nil, comment: "instruction for patch details") }()
    
    // notifications
    
    static var notificationIntros: [String : String] = { return ["Right Stomach" : NSLocalizedString("Change patch on your right stomach at ", comment: "notification telling you where and when to change your patch."),"Left Stomach" : NSLocalizedString("Change patch on your left stomach at ", comment: "notification telling you where and when to change your patch."),"Right Buttock" : NSLocalizedString("Change patch on your right buttock at ", comment: "notification telling you where and when to change your patch."),"Left Buttock" : NSLocalizedString("Change patch on your left buttock at ", comment: "notification telling you where and when to change your patch.")] }()
    
    static var notificationForCustom: String = { return NSLocalizedString("Change patch located on: ", comment: "notification message for a custom located patch") }()
    static var notificationForCustom_at: String = { return NSLocalizedString("at: ", comment: " for displaying the date of the expired patch for a custom located notification, occruing directly after notificationForCustom message") }()
    
    static var notificationSuggestion: String = { return NSLocalizedString("Place new patch here: ", comment: "followed by a suggest location; second line in the notification if and only if the user enabled autoChooseLocation on the SettingsViewcontroller") }()
    
    static var notificationWithoutLocation: String = { return NSLocalizedString("Change a patch at ", comment: "notification when there is no location pressent, this really should never happen") }()
    
    // alerts
    
    static var coreDataSaveAlertTitle: String = NSLocalizedString("Save Error", comment: "this is a title to an alert displayed if patch data is not saved for some reason.")
    
    static var coreDataSaveAlertMessage: String = NSLocalizedString("there was a problem saving your patch data!", comment: "this is a message to an alert displayed if patch data is not saved for some reason.")
    
    static var coreDataAlertTitle: String = NSLocalizedString("Core Data Error", comment: "this is a title to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    
    static var coreDataAlertMessage: String = NSLocalizedString("there is a problem with managed object in the persistent store", comment: "this is a message to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    static var dismiss_string: String = NSLocalizedString("Dismiss", comment: "The word displayed on a button for dismissing an error message")
    
    static var changingNumberOfPatchesAlertTitle: String = NSLocalizedString("Warning", comment: "title for warning the user when they are changing the number of patches in the schedule, a variable to the program")
    
    static var changingNumberOfPatchesAlertMessage: String = NSLocalizedString("Changing the number of patches could result in a loss of data.", comment: "message for warning the user when they are changing the number of patches in the schedule, a variable to the program")
    
    static var accept_string: String = NSLocalizedString("Accept", comment: "an accept button title displayed on the 'changing number of patches' alert")
    
    static var decline_string: String = NSLocalizedString("Decline", comment: "a cancel button title displayed on the 'changing number of patches' alert")
    
    static var resetPatchDataAlertTitle: String = NSLocalizedString("Reset Patch Data", comment: "title of an alert displayed when hitting a reset button")
    
    static var resetPatchDataAlertMessage: String = NSLocalizedString("This action will erase all current patches from the schedule.", comment: "title of an alert displayed when hitting a reset button")
    
    // MARK: - general
    
    static var unplaced_string: String = { return "unplaced"}()
    
    static var entityName: String = { return "Patch" }()
    
    // MARK: - PatchDataController
    
    static var patchPropertyNames: [String] = {return ["datePlaced","location"] }()
    
    static var patchEntityNames: [String] = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
    
    static var patchData: String = { return "patchData" }()
    
    // MARK: - SettingsController
    
    static var settingsChoices: [String] = { return ["interval", "count", "notifications"] }()
    
    static var defaultKeys: [String] = { return ["patchChangeInterval", "numberOfPatches", "autoChooseLocation", "notification", "remindMe"] }()
    
    static func interval() -> String {
        return settingsChoices[0]
    }
    static func count() -> String {
        return settingsChoices[1]
    }
    static func notifications() -> String {
        return settingsChoices[2]
    }
    
    static func patchChangeInterval_string() -> String {
        return defaultKeys[0]
    }
    
    static func numberOfPatches_string() -> String {
        return defaultKeys[1]
    }
    
    static func autoChooseLocation_string() -> String {
        return defaultKeys[2]
    }
    
    static func notificationKey_string() -> String {
        return defaultKeys[3]
    }
    
    static func remindMe_string() -> String {
        return defaultKeys[4]
    }
    
    // MARK: - Colors
    
    static var colorKeys: [String] = { return ["offWhite","lightBlue","cuteGray","lighterCuteGray"] }()
    
    static func offWhite() -> String {
        return colorKeys[0]
    }
    
    static func lightBlue() -> String {
        return colorKeys[1]
    }
    
    static func cuteGray() -> String {
        return colorKeys[2]
    }
    
    static func lighterCuteGray() -> String {
        return colorKeys[3]
    }
    
    
    // MARK: - getting location names
    
    static func rightButt() -> String {
        return patchLocationNames[0]
    }
    
    static func leftButt() -> String {
        return patchLocationNames[1]
    }
    
    static func rightStom() -> String {
        return patchLocationNames[2]
    }
    
    static func leftStom() -> String {
        return patchLocationNames[3]
    }
    
    // MARK: - notification related
    
    static var patchChangeSoonIDs: [Int: String] = [0: "CHANGEPATCH1", 1: "CHANGEPATCH2", 2: "CHANGEPATCH3", 3: "CHANGEPATCH4"]
    
    // MARK: - segue id's
    
    static var scheduleToSettingsID: String = { return "idScheduleToSettingsSegue" }()
    static var settingsToScheduleID: String = { return "idSettingsToScheduleSegue" }()
    static var addPatchSegueID: String = { return "idAddPatchSegue" }()
    
    // MARK: - patch button id's
    static var patchButtonIDs: [String] = { return ["patch1", "patch2", "patch3", "patch4"] }()
    
    
}
