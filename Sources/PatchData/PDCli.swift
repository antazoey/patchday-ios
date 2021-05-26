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

    private static func has(_ flag: String) -> Bool {
        CommandLine.arguments.contains(flag)
    }

    private static func remove(_ flag: String) {
        CommandLine.arguments.removeAll(where: { $0 == flag })
    }
}
