//
//  PDPillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDPillScheduling {
    func takePill(at index: Index, pushSharedData: (() -> ())?)
    func take(_ pill: Swallowable, pushSharedData: (() -> ())?)
    func take(pushSharedData: (() -> ())) 
}
