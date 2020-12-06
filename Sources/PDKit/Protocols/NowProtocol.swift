//
//  NowProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 9/6/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol NowProtocol {
    var now: Date { get }

    func isInYesterday(_ date: Date) -> Bool
}
