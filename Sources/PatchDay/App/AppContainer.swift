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
    }

    // MARK: - Remote CloudKit / KVS observation

    private func observeRemoteCoreDataChanges() {
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
