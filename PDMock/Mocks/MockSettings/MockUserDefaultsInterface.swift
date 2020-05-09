//
//  MockUserDefaultsInterface.swift
//  PDMock
//
//  Created by Juliya Smith on 5/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockUserDefaultsInterface: UserDefaultsProtocol {
	
	public init() {}
	
	public var setCallArgs: [(Any?, String)] = []
	public func set(_ value: Any?, for key: String) {
		setCallArgs.append((value, key))
	}
	
	public var objectCallArgs: [String] = []
	public var objectReturnValue: Any? = nil
	public func object(for key: String) -> Any? {
		objectCallArgs.append(key)
		return objectReturnValue
	}
}
