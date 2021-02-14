//
//  NowProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 9/6/20.

import Foundation

public protocol NowProtocol {
    var now: Date { get }

    func isInYesterday(_ date: Date) -> Bool
}
