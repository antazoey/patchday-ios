//
//  PDNow.swift
//  PDKit
//
//  Created by Juliya Smith on 9/6/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

/// This protocol is useful for writing unit tests for code that is sensitive to when "now" is.
public class PDNow: NowProtocol {
    public init() {}
    public var now: Date { Date() }
}
