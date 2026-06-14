//
//  RootView.swift
//  PatchDay
//
//  Top-level shell. On iPhone/iPad this is the four-tab TabView; on macOS
//  (Mac Catalyst) it's a NavigationSplitView with a sidebar so Hormones,
//  Pills, Sites, and Settings are all reachable from the main window. Both
//  shells share the same per-section NavigationStacks, routes, navigation
//  state (AppContainer.selectedTab + the per-tab paths), and lifecycle
//  modifiers — only the chrome differs.
//

import SwiftUI
import PDKit

struct RootView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.scenePhase) private var scenePhase

    @State private var showSetupSheet: Bool = false

    var body: some View {
        shell
            .preferredColorScheme(container.preferredColorScheme)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    // Only refresh badge counts here — calling triggerRefresh
                    // would bump refreshTick and rebuild every list, losing
                    // scroll and selection state.
                    container.refreshBadges()
                }
            }
            .onAppear(perform: maybePresentSetup)
            .sheet(isPresented: $showSetupSheet) { SetupSheet() }
    }

    /// The platform-specific chrome. Everything inside is shared.
    @ViewBuilder
    private var shell: some View {
        #if targetEnvironment(macCatalyst)
        macSidebar
        #else
        iPhoneTabs
        #endif
    }

    // MARK: - iPhone / iPad tab bar

    private var iPhoneTabs: some View {
        TabView(selection: $container.selectedTab) {

            hormonesStack
                .tabItem {
                    Label { Text(hormonesTabTitle) } icon: {
                        Image(uiImage: PDIcons[hormonesDeliveryMethod])
                    }
                }
                .badge(container.hormonesBadge)
                .tag(AppTab.hormones)

            pillsStack
                .tabItem {
                    Label { Text(PDTitleStrings.PillsTitle) } icon: {
                        Image("Pill Icon")
                    }
                }
                .badge(container.pillsBadge)
                .tag(AppTab.pills)

            sitesStack
                .tabItem {
                    Label { Text(PDTitleStrings.SitesTitle) } icon: {
                        Image("Site Icon")
                    }
                }
                .tag(AppTab.sites)

            settingsStack
                .tabItem {
                    Label { Text(PDTitleStrings.SettingsTitle) } icon: {
                        Image(uiImage: PDIcons.settingsIcon)
                    }
                }
                .tag(AppTab.settings)
        }
    }

    // MARK: - macOS sidebar

    private var macSidebar: some View {
        NavigationSplitView {
            List(selection: sidebarSelection) {
                ForEach(AppTab.sidebarOrder, id: \.self) { tab in
                    sidebarLabel(for: tab)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("PatchDay")
        } detail: {
            detail(for: container.selectedTab)
        }
    }

    /// `List(selection:)` on iOS/Catalyst requires an optional binding, but the
    /// sidebar always has exactly one section selected. Bridge to the
    /// non-optional `container.selectedTab`, ignoring deselection.
    private var sidebarSelection: Binding<AppTab?> {
        Binding(
            get: { container.selectedTab },
            set: { if let tab = $0 { container.selectedTab = tab } }
        )
    }

    @ViewBuilder
    private func sidebarLabel(for tab: AppTab) -> some View {
        switch tab {
        case .hormones:
            Label { Text(hormonesTabTitle) } icon: {
                Image(uiImage: PDIcons[hormonesDeliveryMethod])
            }
            .badge(container.hormonesBadge)
        case .pills:
            Label { Text(PDTitleStrings.PillsTitle) } icon: { Image("Pill Icon") }
                .badge(container.pillsBadge)
        case .sites:
            Label { Text(PDTitleStrings.SitesTitle) } icon: { Image("Site Icon") }
        case .settings:
            Label { Text(PDTitleStrings.SettingsTitle) } icon: {
                Image(uiImage: PDIcons.settingsIcon)
            }
        }
    }

    @ViewBuilder
    private func detail(for tab: AppTab) -> some View {
        switch tab {
        case .hormones: hormonesStack
        case .pills: pillsStack
        case .sites: sitesStack
        case .settings: settingsStack
        }
    }

    // MARK: - Shared per-section navigation stacks

    private var hormonesStack: some View {
        NavigationStack(path: $container.hormonesPath) {
            HormonesListView()
                .navigationDestination(for: HormonesRoute.self) { route in
                    switch route {
                    case .detail(let index):
                        HormoneDetailView(hormoneIndex: index)
                    case .settings:
                        SettingsView()
                    }
                }
        }
    }

    private var pillsStack: some View {
        NavigationStack(path: $container.pillsPath) {
            PillsListView()
                .navigationDestination(for: PillsRoute.self) { route in
                    switch route {
                    case .detail(let index):
                        PillDetailView(pillIndex: index)
                    }
                }
        }
    }

    private var sitesStack: some View {
        NavigationStack(path: $container.sitesPath) {
            SitesListView()
                .navigationDestination(for: SitesRoute.self) { route in
                    switch route {
                    case .detail(let index):
                        SiteDetailView(siteIndex: index)
                    case .presets:
                        SiteSchemePresetsView()
                    }
                }
        }
    }

    private var settingsStack: some View {
        NavigationStack(path: $container.settingsPath) {
            SettingsView()
        }
    }

    // MARK: - Setup sheet

    /// Show the SetupSheet once after install/update if either iCloud sync
    /// or notifications is off and the user hasn't seen it yet.
    private func maybePresentSetup() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: PDLocalSettingsKey.didShowICloudSetup.rawValue) { return }
        let iCloudOff = !defaults.bool(forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue)
        let notificationsOff = !(container.sdk?.settings.notifications.value ?? false)
        if iCloudOff || notificationsOff {
            showSetupSheet = true
        }
    }

    private var hormonesDeliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    private var hormonesTabTitle: String {
        PDTitleStrings.Hormones[hormonesDeliveryMethod]
    }
}
