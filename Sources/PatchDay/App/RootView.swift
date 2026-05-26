//
//  RootView.swift
//  PatchDay
//
//  Hosts the SwiftUI tab bar and the four per-tab NavigationStacks.
//  Hormones is fully SwiftUI; Pills/Sites/Settings stay UIKit-backed via
//  LegacyVCContainer until they are migrated in later sessions.
//

import SwiftUI
import PDKit

struct RootView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $container.selectedTab) {

            // MARK: Hormones (fully SwiftUI)
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
            .tabItem {
                Label {
                    Text(hormonesTabTitle)
                } icon: {
                    Image(uiImage: PDIcons[hormonesDeliveryMethod])
                }
            }
            .badge(container.hormonesBadge)
            .tag(AppTab.hormones)

            // MARK: Pills (fully SwiftUI)
            NavigationStack(path: $container.pillsPath) {
                PillsListView()
                    .navigationDestination(for: PillsRoute.self) { route in
                        switch route {
                        case .detail(let index):
                            PillDetailView(pillIndex: index)
                        }
                    }
            }
            .tabItem {
                Label {
                    Text(PDTitleStrings.PillsTitle)
                } icon: {
                    Image("Pill Icon")
                }
            }
            .badge(container.pillsBadge)
            .tag(AppTab.pills)

            // MARK: Sites (fully SwiftUI)
            NavigationStack(path: $container.sitesPath) {
                SitesListView()
                    .navigationDestination(for: SitesRoute.self) { route in
                        switch route {
                        case .detail(let index):
                            SiteDetailView(siteIndex: index)
                        }
                    }
            }
            .tabItem {
                Label {
                    Text(PDTitleStrings.SitesTitle)
                } icon: {
                    Image("Site Icon")
                }
            }
            .tag(AppTab.sites)

            // MARK: Settings (fully SwiftUI; also reachable via gear from Hormones)
            NavigationStack(path: $container.settingsPath) {
                SettingsView()
            }
            .tabItem {
                Label {
                    Text(PDTitleStrings.SettingsTitle)
                } icon: {
                    Image(uiImage: PDIcons.settingsIcon)
                }
            }
            .tag(AppTab.settings)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // Only refresh badge counts here — calling triggerRefresh would
                // bump refreshTick and rebuild every list, losing scroll and
                // selection state.
                container.refreshBadges()
            }
        }
    }

    private var hormonesDeliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    private var hormonesTabTitle: String {
        PDTitleStrings.Hormones[hormonesDeliveryMethod]
    }
}
