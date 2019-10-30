//
//  PDIndexRebounce.swift
//  PDKit
//
//  Created by Juliya Smith on 10/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDIndexRebounce {
    func rebound(upon attempted: Index, lessThan bound: Index) -> Int
}
