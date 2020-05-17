//
//  PDCli.swift
//  PatchData
//
//  Created by Juliya Smith on 3/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

class PDCli {

	static func isNukeMode() -> Bool {
		CommandLine.arguments.contains("--nuke-storage")
	}

	static func isDebugMode() -> Bool {
		CommandLine.arguments.contains("-d") || CommandLine.arguments.contains("--debug")
	}
	
	static func isNotificationsTest() -> Bool {
		CommandLine.arguments.contains("--notifications-test")
	}
}
