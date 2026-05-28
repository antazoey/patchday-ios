//
//  AppContainer.swift
//  PatchDay
//
//  Single source of truth for app-wide dependencies and SwiftUI navigation
//  state. A singleton constructed at first access — `AppDelegate` and the
//  SwiftUI App both read `AppContainer.shared`.
//

import Foundation
import SwiftUI
import UIKit
import CoreData
import CloudKit
import PDKit
import PatchData
import WidgetKit

final class AppContainer: ObservableObject {

    static let shared = AppContainer()

    // MARK: - Dependencies

    private(set) var sdk: PatchDataSDK?
    private(set) var notifications: NotificationScheduling?
    private(set) var badge: PDBadgeReflective?
    private(set) var widget: PDWidgetProtocol?
    private var kvs: UbiquitousKeyValueStoring?
    private var remoteChangeObserver: NSObjectProtocol?
    private var cloudKitEventObserver: NSObjectProtocol?

    /// Latest persistent-history token we've already consumed. Persisted
    /// across launches so we never re-process old transactions.
    private var lastSeenHistoryToken: NSPersistentHistoryToken? {
        get {
            guard let data = UserDefaults.standard.data(
                forKey: PDLocalSettingsKey.lastHistoryToken.rawValue
            ) else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSPersistentHistoryToken.self, from: data
            )
        }
        set {
            guard let token = newValue else {
                UserDefaults.standard.removeObject(
                    forKey: PDLocalSettingsKey.lastHistoryToken.rawValue
                )
                return
            }
            if let data = try? NSKeyedArchiver.archivedData(
                withRootObject: token, requiringSecureCoding: true
            ) {
                UserDefaults.standard.set(
                    data, forKey: PDLocalSettingsKey.lastHistoryToken.rawValue
                )
            }
        }
    }

    // MARK: - SwiftUI navigation + UI state

    @Published var selectedTab: AppTab = .hormones
    @Published var hormonesPath = NavigationPath()
    @Published var pillsPath = NavigationPath()
    @Published var sitesPath = NavigationPath()
    @Published var settingsPath = NavigationPath()

    @Published var hormonesBadge: Int = 0
    @Published var pillsBadge: Int = 0

    /// Bumped after any mutation that should re-render Hormones / Pills lists.
    @Published var refreshTick = UUID()

    private var isBootstrapped = false

    init() {
        bootstrap()
    }

    // MARK: - Lifecycle

    func bootstrap() {
        guard !isBootstrapped else { return }
        isBootstrapped = true
        let sdk = PatchData()
        self.sdk = sdk
        let badge = PDBadge(sdk: sdk)
        self.badge = badge
        self.notifications = Notifications(sdk: sdk, appBadge: badge)
        self.widget = PDWidget()
        badge.reflect()
        refreshBadges()
        WidgetCenter.shared.reloadAllTimelines()

        observeRemoteCoreDataChanges()
        observeRemoteKVSChanges()
        observeCloudKitEvents()
    }

    // MARK: - Remote CloudKit / KVS observation

    /// Observes `NSPersistentCloudKitContainer.eventChangedNotification`,
    /// which fires for setup / import / export operations. Used to bump the
    /// "Last synced" timestamp in the Settings UI whenever any sync
    /// operation completes successfully — including upload-only flows on a
    /// single device, which `.NSPersistentStoreRemoteChange` doesn't
    /// reliably surface.
    private func observeCloudKitEvents() {
        cloudKitEventObserver = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let event = notification.userInfo?[
                NSPersistentCloudKitContainer.eventNotificationUserInfoKey
            ] as? NSPersistentCloudKitContainer.Event else { return }
            // Always log the latest event for the debug UI, even if it
            // hasn't ended yet — easier to see "import in progress."
            let typeString: String
            switch event.type {
                case .setup: typeString = "setup"
                case .import: typeString = "import"
                case .export: typeString = "export"
                @unknown default: typeString = "unknown"
            }
            let stateString: String
            if event.endDate == nil {
                stateString = "in progress"
            } else if event.succeeded {
                stateString = "succeeded"
            } else {
                stateString = "failed: \(event.error?.localizedDescription ?? "unknown")"
            }
            let description = "\(typeString) — \(stateString)"
            UserDefaults.standard.set(
                description,
                forKey: PDLocalSettingsKey.lastCloudKitEventDescription.rawValue
            )
            // Bump the user-facing Last Synced only on successful completion.
            if event.endDate != nil, event.succeeded {
                UserDefaults.standard.set(
                    event.endDate, forKey: PDLocalSettingsKey.lastICloudSyncDate.rawValue
                )
            }
        }
    }

    // MARK: - Developer-only helpers (DEBUG builds)
    #if DEBUG
    /// Forces a save on the viewContext so CloudKit (if enabled) picks up
    /// a transaction to export. Used by the developer tools to trigger a
    /// visible sync without changing user-visible data.
    func forceCoreDataSave() {
        let context = CoreDataStack.context
        // Touch a no-op change so save has something to export.
        context.processPendingChanges()
        try? context.save()
    }

    /// Best-effort delete of every record from the iCloud private database
    /// for this container. Local store is unaffected; deleting records
    /// from CloudKit will propagate down via the usual remote-change path.
    func purgeICloudData(_ completion: ((Error?) -> Void)? = nil) {
        let container = CKContainer(
            identifier: CoreDataStack.cloudKitContainerIdentifier
        )
        container.privateCloudDatabase.fetchAllRecordZones { zones, error in
            if let error = error {
                DispatchQueue.main.async { completion?(error) }
                return
            }
            guard let zones = zones, !zones.isEmpty else {
                DispatchQueue.main.async { completion?(nil) }
                return
            }
            let zoneIDs = zones.map { $0.zoneID }
            let op = CKModifyRecordZonesOperation(
                recordZonesToSave: nil,
                recordZoneIDsToDelete: zoneIDs
            )
            op.modifyRecordZonesResultBlock = { result in
                DispatchQueue.main.async {
                    if case let .failure(error) = result {
                        completion?(error)
                    } else {
                        completion?(nil)
                    }
                }
            }
            container.privateCloudDatabase.add(op)
        }
    }
    #endif

    private func observeRemoteCoreDataChanges() {
        // .NSPersistentStoreRemoteChange fires for every save, including our
        // own local writes. The handler walks persistent history starting
        // from `lastSeenHistoryToken` and only reloads if it sees a
        // transaction whose author isn't ours — CloudKit imports and writes
        // from other processes (e.g. the widget) qualify; our viewContext
        // writes don't.
        //
        // On first launch (or after Nuke clears the persisted token) seed
        // the token to "now" so we don't treat bootstrap-era transactions
        // (Core Data lightweight migration, default-data seeding) as
        // remote-origin and trigger a spurious reload.
        if lastSeenHistoryToken == nil {
            lastSeenHistoryToken = CoreDataStack.currentHistoryToken()
        }
        remoteChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleRemoteCoreDataChange()
        }
    }

    private func observeRemoteKVSChanges() {
        let isSyncEnabled = UserDefaults.standard.bool(
            forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue
        )
        guard isSyncEnabled else { return }
        let store = PDUbiquitousKVStore()
        self.kvs = store
        store.startObserving { [weak self] _ in
            // KVS changes affect settings only; the schedules don't need a
            // hard reload, but we do want widgets / notifications to refresh.
            self?.refreshBadges()
            self?.notifications?.cancelAllExpiredHormoneNotifications()
            self?.notifications?.requestAllExpiredHormoneNotifications()
            WidgetCenter.shared.reloadAllTimelines()
            UserDefaults.standard.set(
                Date(), forKey: PDLocalSettingsKey.lastICloudSyncDate.rawValue
            )
        }
    }

    private func handleRemoteCoreDataChange() {
        let (latest, sawRemote) = CoreDataStack.consumeRemoteHistory(
            after: lastSeenHistoryToken
        )
        lastSeenHistoryToken = latest
        guard sawRemote else { return }

        // Drop in-memory entity caches; the schedules will refetch.
        sdk?.hormones.reloadContext()
        sdk?.pills.reloadContext()
        sdk?.sites.reloadContext()

        // Re-share derived widget values + reschedule notifications.
        sdk?.hormones.shareData()
        sdk?.pills.shareData()
        notifications?.cancelAllExpiredHormoneNotifications()
        notifications?.requestAllExpiredHormoneNotifications()
        notifications?.cancelAllDuePillNotifications()
        notifications?.requestAllDuePillNotifications()

        triggerRefresh()
        WidgetCenter.shared.reloadAllTimelines()
        UserDefaults.standard.set(
            Date(), forKey: PDLocalSettingsKey.lastICloudSyncDate.rawValue
        )
    }

    // MARK: - Badge counts (drive the SwiftUI tab bar)

    func refreshBadges() {
        hormonesBadge = sdk?.hormones.totalExpired ?? 0
        pillsBadge = sdk?.pills.totalDue ?? 0
        badge?.reflect()
    }

    func triggerRefresh() {
        refreshTick = UUID()
        refreshBadges()
    }

    // MARK: - Navigation helpers

    func goToHormoneDetail(_ index: Index) {
        hormonesPath.append(HormonesRoute.detail(index: index))
    }

    func goToSettings() {
        hormonesPath.append(HormonesRoute.settings)
    }

    func popHormones() {
        guard !hormonesPath.isEmpty else { return }
        hormonesPath.removeLast()
    }

    func goToPillDetail(_ index: Index) {
        pillsPath.append(PillsRoute.detail(index: index))
    }

    func popPills() {
        guard !pillsPath.isEmpty else { return }
        pillsPath.removeLast()
    }

    func goToSiteDetail(_ index: Index) {
        sitesPath.append(SitesRoute.detail(index: index))
    }

    func popSites() {
        guard !sitesPath.isEmpty else { return }
        sitesPath.removeLast()
    }

    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
