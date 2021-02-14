//
//  PDCli.swift
//  PatchData
//
//  Created by Juliya Smith on 3/28/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PDCli {

    private static let NukeFlag = "--nuke-storage"
    private static let DebugFlag = "--debug"
    private static let DebugFlagShort = "-d"
    private static let NotificationsTestFlag = "--notifications-test"

    public static func isNukeMode() -> Bool {
        CommandLine.arguments.contains(NukeFlag)
    }

    public static func clearNukeFlag() {
        CommandLine.arguments.removeAll(where: { $0 == NukeFlag })
    }

    public static func isDebugMode() -> Bool {
        CommandLine.arguments.contains(DebugFlagShort) || CommandLine.arguments.contains(DebugFlag)
    }

    public static func isNotificationsTest() -> Bool {
        CommandLine.arguments.contains(NotificationsTestFlag)
    }

    public static func clearNotificationsFlag() {
        CommandLine.arguments.removeAll(where: { $0 == NotificationsTestFlag })
    }
}
