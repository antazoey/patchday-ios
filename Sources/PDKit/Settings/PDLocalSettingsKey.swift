//
//  PDLocalSettingsKey.swift
//  PDKit
//
//  Keys for device-local UserDefaults — never sync via iCloud / KVS.
//

import Foundation

public enum PDLocalSettingsKey: String, CaseIterable {
    case iCloudSyncEnabled
    case didShowICloudSetup
    case didMigrateStoreToAppGroup
    case lastICloudSyncDate
    case lastICloudSyncStatus
    case lastHistoryToken
    case didSeed40Defaults
    case wipeLocalStoreOnNextLaunch
    case lastCloudKitEventDescription
    case didSeedKVSFromLocal
    case theme
}
