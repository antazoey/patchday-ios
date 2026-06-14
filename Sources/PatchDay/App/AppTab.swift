//
//  AppTab.swift
//  PatchDay
//
//  Top-level tab identifiers and per-tab navigation routes used by RootView's
//  TabView and the four NavigationStacks. Routes are Hashable so they can be
//  appended to NavigationPath and resolved via .navigationDestination(for:).
//

import Foundation
import PDKit

enum AppTab: Hashable, CaseIterable {
    case hormones
    case pills
    case sites
    case settings

    /// Order the sections appear in, used by both the iPhone tab bar and the
    /// macOS sidebar. Mirrors `allCases` declaration order so the two shells
    /// can never drift apart.
    static var sidebarOrder: [AppTab] { allCases }
}

enum HormonesRoute: Hashable {
    case detail(index: Index)
    case settings
}

enum PillsRoute: Hashable {
    case detail(index: Index)
}

enum SitesRoute: Hashable {
    case detail(index: Index)
    case presets
}
