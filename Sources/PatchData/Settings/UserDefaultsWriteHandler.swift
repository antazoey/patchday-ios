//
//  UserDefaultsWriteHandler.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//

import Foundation
import PDKit

public class UserDefaultsWriteHandler: NSObject, UserDefaultsWriteHandling {

    override open var description: String { "Handles pushing and pulling from UserDefaults." }

    private var base: UserDefaultsProtocol
    private var dataSharer: UserDefaultsProtocol
    private var kvs: UbiquitousKeyValueStoring
    private let isSyncEnabled: () -> Bool

    /// Settings that participate in cross-device sync. `MentionedDisclaimer`
    /// is a per-device legal acknowledgement; `SiteIndex` is a per-device
    /// rotation cursor. Everything else is shared across the user's devices.
    static let syncedKeys: Set<String> = [
        PDSetting.DeliveryMethod.rawValue,
        PDSetting.ExpirationInterval.rawValue,
        PDSetting.XDays.rawValue,
        PDSetting.Quantity.rawValue,
        PDSetting.Notifications.rawValue,
        PDSetting.NotificationsMinutesBefore.rawValue,
        PDSetting.PillsEnabled.rawValue,
        PDSetting.UseStaticExpirationTime.rawValue
    ]

    public convenience init(dataSharer: UserDefaultsProtocol) {
        self.init(
            baseDefaults: PDUserDefaults(),
            dataSharer: dataSharer,
            kvs: NoOpUbiquitousKVStore(),
            isSyncEnabled: { false }
        )
    }

    public convenience init(
        baseDefaults: UserDefaultsProtocol,
        dataSharer: UserDefaultsProtocol
    ) {
        self.init(
            baseDefaults: baseDefaults,
            dataSharer: dataSharer,
            kvs: NoOpUbiquitousKVStore(),
            isSyncEnabled: { false }
        )
    }

    public init(
        baseDefaults: UserDefaultsProtocol,
        dataSharer: UserDefaultsProtocol,
        kvs: UbiquitousKeyValueStoring,
        isSyncEnabled: @escaping () -> Bool
    ) {
        self.base = baseDefaults
        self.dataSharer = dataSharer
        self.kvs = kvs
        self.isSyncEnabled = isSyncEnabled
    }

    public func replace<T>(_ v: T, to newValue: T.RawValue) where T: KeyStorable {
        let key = v.setting.rawValue
        dataSharer.set(newValue, for: key)
        base.set(newValue, for: key)
        if isSyncEnabled(), Self.syncedKeys.contains(key) {
            kvs.set(newValue, for: key)
        }
    }

    public func load<T>(_ setting: PDSetting) -> T? {
        let key = setting.rawValue
        if let v = dataSharer.object(for: key) as? T { return v }
        if let v = base.object(for: key) as? T { return v }
        if isSyncEnabled(), Self.syncedKeys.contains(key) {
            return kvs.object(for: key) as? T
        }
        return nil
    }

    /// Push every locally-stored synced setting into iCloud KVS. Runs once
    /// on the first iCloud-enabled launch so values that have been in
    /// local UserDefaults since 3.x — and never re-written in 4.x —
    /// actually end up in the cloud for other devices to pick up.
    public func pushAllSyncedToKVS() {
        for key in Self.syncedKeys {
            if let value = base.object(for: key) {
                kvs.set(value, for: key)
            }
        }
    }

    /// Mirror remote KVS changes into the local stores so the in-app cache
    /// stays consistent. Caller should subscribe to the KVS observer and
    /// pass through the changed-keys array.
    public func ingestKVSChanges(_ changedKeys: [String]) {
        for key in changedKeys where Self.syncedKeys.contains(key) {
            let value = kvs.object(for: key)
            base.set(value, for: key)
            dataSharer.set(value, for: key)
        }
    }
}
