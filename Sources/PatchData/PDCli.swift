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

    // MARK: - Private

    // Snapshot CommandLine.arguments once at launch. Swift is deprecating
    // setter access to CommandLine.arguments, but PDCli needs to mutate
    // its own copy to clear one-shot flags (nuke, wakeup test) after
    // they've been consumed so they don't re-fire on re-entrant init.
    private static var arguments: [String] = CommandLine.arguments

    private static func has(_ flag: String) -> Bool {
        arguments.contains(flag)
    }

    private static func remove(_ flag: String) {
        arguments.removeAll(where: { $0 == flag })
    }
}
