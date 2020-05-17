//
//  File.swift
//  PDKit
//
//  Created by Juliya Smith on 5/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDObserving {
	func add(source: AnyObject, selector: Selector)
}
