//
//  EstrogenScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol EstrogenScheduling: PDScheduling {
    func totalDue(_ interval: ExpirationIntervalUD) -> Int
    func reset(from start: Index)
    func getIndex(for estrogen: TimeReleased) -> Index?
}
