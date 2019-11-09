//
//  PDBadgeDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

protocol PDBadgeDelegate {
    func increment()
    func decrement()
    func set(to newBadgeValue: Int)
}
