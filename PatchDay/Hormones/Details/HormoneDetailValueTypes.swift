//
// Created by Juliya Smith on 1/1/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

public struct HormoneViewStrings {
	public init(_ exp: String, _ date: String, _ site: String) {
		self.expirationText = exp
		self.dateAndTimePlacedText = date
		self.siteLabelText = site
	}
	public var expirationText: String
	public var dateAndTimePlacedText: String
	public var siteLabelText: String
}
