//
//  PDPillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDPillScheduling: PDSchedule {
    var all: [Swallowable] { get }
    var nextDue: Swallowable? { get }
    var totalDue: Int { get }
    func insertNew(completion: (() -> ())?) -> Swallowable?
    func delete(at index: Index)
    func at(_ index: Index) -> Swallowable?
    func get(for id: UUID) -> Swallowable?
    func set(at index: Index, with attributes: PillAttributes)
    func set(for pill: Swallowable, with attributes: PillAttributes)
    func setAsDefault()
    func swallow(at index: Index, pushSharedData: (() -> ())?)
    func swallow(_ pill: Swallowable, pushSharedData: (() -> ())?)
    func swallow(pushSharedData: (() -> ())?)
}
