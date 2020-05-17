//
//  MockObservatory.swift
//  PDMock
//
//  Created by Juliya Smith on 5/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockObservatory: PDObserving {
	
	public init() {}
	
	public var addCallArgs: [(AnyObject, Selector)] = []
	public func add(source: AnyObject, selector: Selector) {
		addCallArgs.append((source, selector))
	}
}
