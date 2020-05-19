//
//  PDCli.swift
//  PatchData
//
//  Created by Juliya Smith on 3/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public class PDCli {

	public static func isNukeMode() -> Bool {
		CommandLine.arguments.contains("--nuke-storage")
	}

	public static func isDebugMode() -> Bool {
		CommandLine.arguments.contains("-d") || CommandLine.arguments.contains("--debug")
	}
	
	public static func isNotificationsTest() -> Bool {
		CommandLine.arguments.contains("--notifications-test")
	}
}
