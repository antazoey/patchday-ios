//
//  PatchDayApp.swift
//  PatchDay
//
//  SwiftUI App lifecycle entry point. Replaces @UIApplicationMain in
//  AppDelegate.swift. The UIApplicationDelegateAdaptor keeps AppDelegate
//  alive for system callbacks and for legacy VCs that still resolve
//  dependencies via AppDelegate.current.
//

import SwiftUI

@main
struct PatchDayApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .onAppear {
                    container.refreshBadges()
                }
        }
    }
}
