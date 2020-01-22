//
//  PillSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit


public class PillSchedule: NSObject, PillScheduling {
    
    override public var description: String { "Schedule for pills." }

    private let log = PDLog<PillSchedule>()
    
    private var pills: [Swallowable]
    private let store: PillStoring
    private let sharer: PillDataSharing
    
    enum PillScheduleState {
        case Initial
        case Working
    }
    
    init(store: PillStoring, pillDataSharer: PillDataSharing, state: PillScheduleState) {
        self.store = store
        self.sharer = pillDataSharer
        self.pills = store.getStoredPills()
        super.init()
        if state == .Initial {
            log.info("Pill state is initial - Setting up default Pills")
            self.reset()
        }
        awaken()
    }
    
    public var all: [Swallowable] { pills }

    public var count: Int { pills.count }
    
    public var nextDue: Swallowable? {
        pills.min(by: PillComparator.lessThan)
    }

    public var totalDue: Int {
        pills.reduce(0, {
            (count: Int, pill: Swallowable) -> Int in pill.isDue ? 1 + count : count
        })
    }
    
    // MARK: - Override base class

    public func insertNew(completion: (() -> ())?) -> Swallowable? {
        if let pill = store.createNewPill() {
            pills.append(pill)
            store.pushLocalChangesToManagedContext([pill], doSave: true)
            completion?()
            shareData()
            return pill
        }
        return nil
    }

    public func delete(at index: Index) {
        if let pill = at(index) {
            store.delete(pill)
            shareData()
        }
    }

    public func reset() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = store.createNewPill(name: names[i]) {
                pill.reset()
                pills.append(pill)
            }
        }
        store.pushLocalChangesToManagedContext(pills, doSave: true)
    }

    // MARK: - Public

    public func at(_ index: Index) -> Swallowable? {
        pills.tryGet(at: index)
    }

    public func get(by id: UUID) -> Swallowable? {
        pills.first(where: { p in p.id == id })
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        if var pill = at(index) {
            set(&pill, with: attributes)
        }
    }

    public func set(by id: UUID, with attributes: PillAttributes) {
        if var pill = get(by: id) {
            set(&pill, with: attributes)
        }
    }

    public func swallow(at index: Index, completion: (() -> ())?) {
        if let pill = at(index) {
            swallow(pill, completion: completion) // Saves
        }
    }

    public func swallow(_ pill: Swallowable, completion: (() -> ())?) {
        swallow(pill) // Saves
        completion?()
    }

    public func swallow(_ pill: Swallowable) {
        if pill.timesTakenToday < pill.timesaday {
            pill.swallow()
            store.pushLocalChangesToManagedContext([pill], doSave: true)
        }
    }

    public func swallow(completion: (() -> ())? = nil) {
        if let next = nextDue {
            swallow(next, completion: completion)
        }
    }
    
    public func firstIndexOf(_ pill: Swallowable) -> Index? {
        pills.firstIndex { (_ p: Swallowable) -> Bool in p.isEqualTo(pill) }
    }
    
    public func shareData() {
        if let next = nextDue {
            sharer.share(nextPill: next)
        }
    }
    
    // MARK: - Private
    
    private func set(_ pill: inout Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        store.pushLocalChangesToManagedContext([pill], doSave: true)
        shareData()
    }

    private func awaken() {
        for pill in pills {
            pill.awaken()
        }
        store.pushLocalChangesToManagedContext(pills, doSave: true)
    }
    
    private func deleteAll() {
        pills.forEach { (_ p: Swallowable) -> () in store.delete(p) }
        pills = []
    }
}
