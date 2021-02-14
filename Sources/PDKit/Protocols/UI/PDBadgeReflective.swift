//
//  PDBadgeReflective.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.

import Foundation

public protocol PDBadgeReflective {
    var value: Int { get }
    func clear()
    func reflect()
}
