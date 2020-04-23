//
//  DataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 1/18/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class DataSharer: DataSharing {

	private var sharedDefaults: UserDefaults? {
		UserDefaults(suiteName: "group.com.patchday.todaydata")
	}

	public func share(_ value: Any?, forKey key: String) {
		sharedDefaults?.set(value, forKey: key)
	}

	public func object(forKey key: String) -> Any? {
		sharedDefaults?.object(forKey: key)
	}
}
