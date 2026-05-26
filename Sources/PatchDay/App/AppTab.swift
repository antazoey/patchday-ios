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

enum AppTab: Hashable {
    case hormones
    case pills
    case sites
    case settings
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
}
