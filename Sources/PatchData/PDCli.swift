//
//  PDCli.swift
//  PatchData
//
//  Created by Juliya Smith on 3/28/20.

import Foundation

public class PDCli {

    private static let NukeFlag = "--nuke-storage"
    private static let DebugFlag = "--debug"
    private static let DebugFlagShort = "-d"
    private static let NotificationsTestFlag = "--notifications-test"
    private static let WakeUpTestFlag = "--wakeup-test"
    private static let DemoStateFlag = "--demo-state"

    // MARK: - Arg Existence Checking

    public static func isDebugMode() -> Bool {
        has(DebugFlagShort) || has(DebugFlag)
    }

    public static func isNukeMode() -> Bool {
        has(NukeFlag)
    }

    public static func isNotificationsTest() -> Bool {
        has(NotificationsTestFlag)
    }

    public static func isWakeUpTest() -> Bool {
        has(WakeUpTestFlag)
    }

    public static func isDemoState() -> Bool {
        has(DemoStateFlag)
    }

    // MARK: - Clearing Args

    public static func clearNukeFlag() {
        remove(NukeFlag)
    }

    public static func clearNotificationsFlag() {
        remove(NotificationsTestFlag)
    }

    public static func clearWakeUpFlag() {
        remove(WakeUpTestFlag)
    }

    // MARK: - Scheduling (DEBUG developer-tools only)

    /// UserDefaults key whose value is the launch flag a developer-tools
    /// button asked PDCli to honor on the next cold launch. PDCli treats
    /// this as if the flag were also passed on the command line.
    private static let scheduledFlagKey = "PDCli.scheduledFlagForNextLaunch"

    /// Persist a launch flag so it fires on the next cold launch even
    /// when the user can't reach the Xcode scheme editor (e.g. running
    /// on a real device via TestFlight). Cleared by `remove(_:)` once
    /// PDCli has consumed it.
    public static func scheduleForNextLaunch(_ flag: String) {
        UserDefaults.standard.set(flag, forKey: scheduledFlagKey)
    }

    // MARK: - Private

    // Snapshot CommandLine.arguments once at launch. Swift is deprecating
    // setter access to CommandLine.arguments, but PDCli needs to mutate
    // its own copy to clear one-shot flags (nuke, wakeup test) after
    // they've been consumed so they don't re-fire on re-entrant init.
    private static var arguments: [String] = {
        var args = CommandLine.arguments
        if let scheduled = UserDefaults.standard.string(forKey: scheduledFlagKey) {
            args.append(scheduled)
        }
        return args
    }()

    private static func has(_ flag: String) -> Bool {
        arguments.contains(flag)
    }

    private static func remove(_ flag: String) {
        arguments.removeAll(where: { $0 == flag })
        // Also clear from persistence so it doesn't fire next launch too.
        if UserDefaults.standard.string(forKey: scheduledFlagKey) == flag {
            UserDefaults.standard.removeObject(forKey: scheduledFlagKey)
        }
    }
}
