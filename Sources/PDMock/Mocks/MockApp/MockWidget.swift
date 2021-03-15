//
//  MockWidget.swift
//  PDKit
//
//  Created by Juliya Smith on 3/15/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockWidget: PDWidgetProtocol {

    public var setCallCount = 0
    public func set() {
        setCallCount += 1
    }
}
