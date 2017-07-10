//
//  PDCloudStorage.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import CloudKit

class UbiquitousKeyValueStoreController {
    
    var store: NSUbiquitousKeyValueStore = { return NSUbiquitousKeyValueStore.default() }()
    
    // MARK: - core data cloud
    
    public var patchA_datePlaced: Date?
    public var patchB_datePlaced: Date?
    public var patchC_datePlaced: Date?
    public var patchD_datePlaced: Date?
    
    public var patchA_location: String?
    public var patchB_location: String?
    public var patchC_location: String?
    public var patchD_location: String?
    
    
    // MARK: - defaults
    
    public var patchCount: Int?
    public var expirationInterval: String?
    public var autoChooseLocation: Bool?
    public var notificationTime: Int?
    public var notifyMe: Bool?
    public var mentionedNotifications: Bool?
    
    public func becomeLive() {
        
        // settings 
        
        patchCountSetUp()
        expIntervalSetUp()
        autoChooseSetUp()
        notificationTimeSetUp()
        notifyMeSetUp()
        
        // core data
        
        setUpPatches()
    }
    
    // MARK: - setters (Settings)
    
    public func set(numberOfPatches: Int) {
        patchCount = numberOfPatches
        store.set(numberOfPatches, forKey: PatchDayStrings.numberOfPatches_string())
        store.synchronize()
    }
    
    public func set(expirationInterval: String) {
        self.expirationInterval = expirationInterval
        store.set(expirationInterval, forKey: PatchDayStrings.patchChangeInterval_string())
        store.synchronize()
    }
    
    public func set(autoChooseLocation: Bool) {
        self.autoChooseLocation = autoChooseLocation
        store.set(autoChooseLocation, forKey: PatchDayStrings.autoChooseLocation_string())
        store.synchronize()
    }
    
    public func setNotificationTime(with: Int) {
        notificationTime = with
        store.set(with, forKey: PatchDayStrings.notificationKey_string())
        store.synchronize()
    }
    
    public func setNotifyMe(with: Bool) {
        notifyMe = with
        store.set(with, forKey: PatchDayStrings.remindMe_string())
        store.synchronize()
    }
    
    // MARK: - setters (Core Data) 
    
    // date placed
    
    public func setPatchADP(with: Date) {
        self.patchA_datePlaced = with
        store.set(with, forKey: "patchADP")
        store.synchronize()
    }
    
    public func setPatchBDP(with: Date) {
        self.patchB_datePlaced = with
        store.set(with, forKey: "patchBDP")
        store.synchronize()
    }
    
    public func setPatchCDP(with: Date) {
        self.patchC_datePlaced = with
        store.set(with, forKey: "patchCDP")
        store.synchronize()
    }
    
    public func setPatchDDP(with: Date) {
        self.patchD_datePlaced = with
        store.set(with, forKey: "patchDDP")
        store.synchronize()
    }
    
    // locations
    
    public func setPatchALoc(with: String) {
        self.patchA_location = with
        store.set(with, forKey: "patchALoc")
        store.synchronize()
    }
    
    public func setPatchBLoc(with: String) {
        self.patchB_location = with
        store.set(with, forKey: "patchBLoc")
        store.synchronize()
    }
    
    public func setPatchCLoc(with: String) {
        self.patchC_location = with
        store.set(with, forKey: "patchCLoc")
        store.synchronize()
    }
    
    public func setPatchDLoc(with: String) {
        self.patchD_location = with
        store.set(with, forKey: "patchDLoc")
        store.synchronize()
    }
    
    // MARK: - Existential Settings
    
    public func existsExpirationInterval() -> Bool {
        return expirationInterval != nil
    }
    
    public func existsPatchCount() -> Bool {
        return patchCount != nil
    }
    
    public func existsAutoChooseLocation() -> Bool {
        return autoChooseLocation != nil
    }
    
    public func existsNotificationTime() -> Bool {
        return notificationTime != nil
    }
    
    public func existsNotifyMe() -> Bool {
        return notifyMe != nil
    }
    
    // MARK: - Existential Core Data
    
    // date placed
    
    public func existsPatchADP() -> Bool {
        return patchA_datePlaced != nil
    }
    
    public func existsPatchBDP() -> Bool {
        return patchB_datePlaced != nil
    }
    
    public func existsPatchCDP() -> Bool {
        return patchC_datePlaced != nil
    }
    
    public func existsPatchDDP() -> Bool {
        return patchD_datePlaced != nil
    }
    
    // locations
    
    public func existsPatchAloc() -> Bool {
        return patchA_location != nil
    }
    
    public func existsPatchBloc() -> Bool {
        return patchB_location != nil
    }
    
    public func existsPatchCloc() -> Bool {
        return patchC_location != nil
    }
    
    public func existsPatchDloc() -> Bool {
        return patchD_location != nil
    }
    
    // MARK: - Ubiquity and observation
    
    private func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousKeyValueStoreDidChangeExternally), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
    }
    
    @objc private func ubiquitousKeyValueStoreDidChangeExternally() {
        
        // settings
        patchCount = store.value(forKey: PatchDayStrings.numberOfPatches_string()) as? Int
        expirationInterval = store.string(forKey: PatchDayStrings.patchChangeInterval_string())
        autoChooseLocation = store.value(forKey: PatchDayStrings.autoChooseLocation_string()) as? Bool
        notificationTime = store.value(forKey: PatchDayStrings.notificationKey_string()) as? Int
        notifyMe = store.value(forKey: PatchDayStrings.remindMe_string()) as? Bool
        
        // core data
        
        // date placed
        
        patchA_datePlaced = store.value(forKey: "patchADP") as? Date
        patchB_datePlaced = store.value(forKey: "patchBDP") as? Date
        patchC_datePlaced = store.value(forKey: "patchCDP") as? Date
        patchD_datePlaced = store.value(forKey: "patchDDP") as? Date
        
        // locations
        
        patchA_location = store.string(forKey: "patchALoc")
        patchB_location = store.string(forKey: "patchBLoc")
        patchC_location = store.string(forKey: "patchCLoc")
        patchD_location = store.string(forKey: "patchDLoc")
        
        
    }

    // MARK: - private (settings)
    
    
    private func patchCountSetUp() {
        if let count: Int = store.object(forKey: PatchDayStrings.numberOfPatches_string()) as? Int {
            patchCount = count
        }
    }
    
    private func expIntervalSetUp() {
        if let interval: String = store.string(forKey: PatchDayStrings.patchChangeInterval_string()) {
            expirationInterval = interval
        }
    }
    
    private func autoChooseSetUp() {
        if let auto: Bool = store.object(forKey: PatchDayStrings.autoChooseLocation_string()) as? Bool {
            autoChooseLocation = auto
        }
    }
    
    private func notificationTimeSetUp() {
        if let notify: Int = store.object(forKey: PatchDayStrings.notificationKey_string()) as? Int {
            notificationTime = notify
        }
    }
    
    private func notifyMeSetUp() {
        if let yesNotify: Bool = store.object(forKey: PatchDayStrings.remindMe_string()) as? Bool {
            notifyMe = yesNotify
        }
    }
    
    // MARK: - private (core data)
    
    private func setUpPatches() {
        
        // date placed 
        
        if let aDate: Date = store.object(forKey: "patchADP") as? Date {
            patchA_datePlaced = aDate
        }
        if let bDate: Date = store.object(forKey: "patchBDP") as? Date {
            patchB_datePlaced = bDate
        }
        if let cDate: Date = store.object(forKey: "patchCDP") as? Date {
            patchC_datePlaced = cDate
        }
        if let dDate: Date = store.object(forKey: "patchDDP") as? Date {
            patchD_datePlaced = dDate
        }
        
        // locations
        
        if let aLoc: String = store.string(forKey: "patchALoc") {
            patchA_location = aLoc
        }
        
        if let bLoc: String = store.string(forKey: "patchBLoc") {
            patchB_location = bLoc
        }
        
        if let cLoc: String = store.string(forKey: "patchCLoc") {
            patchC_location = cLoc
        }
        
        if let dLoc: String = store.string(forKey: "patchDLoc") {
            patchD_location = dLoc
        }
    }
    
    // MARK: - public core data
    
    public func getPatchDate(fromIndex: Int) -> Date? {
        let dates = [patchA_datePlaced, patchB_datePlaced, patchC_datePlaced, patchD_datePlaced]
        if let date = dates[fromIndex] {
            return date
        }
        return nil
    }
    
    public func getPatchLocation(fromIndex: Int) -> String? {
        let locs = [patchA_location, patchB_location, patchC_location, patchD_location]
        if let loc = locs[fromIndex] {
            return loc
        }
        return nil
    }
    
    public func setPatchDate(fromIndex: Int, with: Date) {
        var dates = [patchA_datePlaced, patchB_datePlaced, patchC_datePlaced, patchD_datePlaced]
        if fromIndex >= 0 && fromIndex < SettingsController.getNumberOfPatchesInt() {
            // find which date attribute to set
            if dates[fromIndex] == patchA_datePlaced {
                self.setPatchADP(with: with)
            }
            else if dates[fromIndex] == patchB_datePlaced {
                self.setPatchBDP(with: with)
            }
            else if dates[fromIndex] == patchC_datePlaced {
                self.setPatchCDP(with: with)
            }
            else if dates[fromIndex] == patchD_datePlaced {
                self.setPatchDDP(with: with)
            }
        }
    }
    
    public func setPatchLocation(fromIndex: Int, with: String) {
        print(fromIndex)
        let locs = [patchA_location, patchB_location, patchC_location, patchD_location]
        if fromIndex >= 0 && fromIndex < SettingsController.getNumberOfPatchesInt() {
            // find which location attribute to set
            if locs[fromIndex] == patchA_location {
                self.setPatchALoc(with: with)
            }
            else if locs[fromIndex] == patchB_location {
                self.setPatchBLoc(with: with)
            }
            else if locs[fromIndex] == patchC_location {
                self.setPatchCLoc(with: with)
            }
            else if locs[fromIndex] == patchD_location {
                self.setPatchDLoc(with: with)
            }
        }
    }
    
    public func resetPatches() {
        patchA_datePlaced = nil
        patchB_datePlaced = nil
        patchC_datePlaced = nil
        patchD_datePlaced = nil
        patchA_location = nil
        patchB_location = nil
        patchC_location = nil
        patchD_location = nil
        store.removeObject(forKey: "patchADP")
        store.removeObject(forKey: "patchBDP")
        store.removeObject(forKey: "patchCDP")
        store.removeObject(forKey: "patchDDP")
        store.removeObject(forKey: "patchALoc")
        store.removeObject(forKey: "patchBLoc")
        store.removeObject(forKey: "patchCLoc")
        store.removeObject(forKey: "patchDLoc")
        
    }
}
