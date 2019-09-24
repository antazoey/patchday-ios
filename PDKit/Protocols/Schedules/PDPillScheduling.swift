//
//  PDPillScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDPillScheduling: PDSchedule {
    var get: [Swallowable] { get }
    var nextDue: Swallowable? { get }
    var totalDue: Int { get }
    func insert(completion: (() -> ())?) -> Swallowable?
    func delete(at index: Index)
    func new()
    func at(_ index: Index) -> Swallowable?
    func getPill(for id: UUID) -> Swallowable?
    func setPill(at index: Index, with attributes: PillAttributes)
    func setPill(for pill: Swallowable, with attributes: PillAttributes)
    func swallowPill(at index: Index, pushSharedData: (() -> ())?)
    func swallow(_ pill: Swallowable, pushSharedData: (() -> ())?)
    func swallow(pushSharedData: (() -> ())?)
}
