//
//  DataSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 1/18/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public protocol DataSharing {
	func share(_ value: Any?, forKey key: String)
	func object(forKey key: String) -> Any?
}
