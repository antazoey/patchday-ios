//
//  UserDefaultsWriteHandler.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class UserDefaultsWriteHandler: NSObject, UserDefaultsWriteHandling {

	override open var description: String { "Handles pushing and pulling from UserDefaults." }

	private let stdDefaults = UserDefaults.standard
	private var dataSharer: DataSharing

	public init(dataSharer: DataSharing) {
		self.dataSharer = dataSharer
	}

	public func replace<T>(_ v: inout T, to newValue: T.RawValue) where T: KeyStorable {
		v.rawValue = newValue
		dataSharer.share(newValue, forKey: v.setting.rawValue)
		stdDefaults.set(newValue, forKey: v.setting.rawValue)
	}

	public func load<T>(setting: PDSetting, defaultValue: T) -> T {
		let s1 = dataSharer.object(forKey: setting.rawValue) as? T
		let s2 = stdDefaults.object(forKey: setting.rawValue) as? T
		return s1 ?? s2 ?? defaultValue
	}
}
