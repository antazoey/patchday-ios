//
//  PDLocalSettingsKey.swift
//  PDKit
//
//  Keys for device-local UserDefaults — never sync via iCloud / KVS.
//

import Foundation

public enum PDLocalSettingsKey: String {
    case iCloudSyncEnabled
    case didShowICloudSetup
    case didMigrateStoreToAppGroup
    case lastICloudSyncDate
    case lastICloudSyncStatus
}
