//
//  PDCloudStorage.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import CloudKit

class PDiCloudKeyValueStoreController {
    
    var store: NSUbiquitousKeyValueStore = { return NSUbiquitousKeyValueStore.default() }()
    
    // MARK: - defaults
    
    public var patchCount: Int?
    public var expirationInterval: String?
    public var autoChooseLocation: Bool?
    public var notificationTime: Int?
    public var notifyMe: Bool?
    
    public func becomeLive() {
        patchCountSetUp()
        expIntervalSetUp()
        autoChooseSetUp()
        notificationTimeSetUp()
        notifyMeSetUp()
    }
    
    // MARK: - setters
    
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
    }
    
    // MARK: - Existential
    
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
    
    // MAR: - Ubiquity and observation
    
    private func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousKeyValueStoreDidChangeExternally), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store)
    }
    
    @objc private func ubiquitousKeyValueStoreDidChangeExternally() {
        patchCount = store.value(forKey: PatchDayStrings.numberOfPatches_string()) as? Int
        expirationInterval = store.string(forKey: PatchDayStrings.patchChangeInterval_string())
        autoChooseLocation = store.value(forKey: PatchDayStrings.autoChooseLocation_string()) as? Bool
        notificationTime = store.value(forKey: PatchDayStrings.notificationKey_string()) as? Int
        notifyMe = store.value(forKey: PatchDayStrings.remindMe_string()) as? Bool
    }

    // MARK: - private
    
    
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
    

}
