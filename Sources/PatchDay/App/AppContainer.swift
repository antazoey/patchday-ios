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
