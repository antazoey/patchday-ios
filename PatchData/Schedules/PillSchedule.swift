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
    private let store: PillStore
    private let meter: DataShareDelegate
    
    enum PillScheduleState {
        case Initial
        case Working
    }
    
    init(coreDataStack: PDCoreDataDelegate, pillDataMeter: DataShareDelegate, state: PillScheduleState) {
        let store = PillStore(coreDataStack)
        self.store = store
        self.meter = pillDataMeter
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
        if let pills = pills as? [Pill] {
            return pills.min(by: PillComparator.lessThan)
        }
        return nil
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
            store.pushLocalChangesToBeSaved(pill)
            completion?()
            broadcastData()
            return pill
        }
        return nil
    }

    public func delete(at index: Index) {
        if let pill = at(index) {
            store.delete(pill)
            broadcastData()
        }
    }

    public func reset() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = store.createNewPill(name: names[i]) {
                pills.append(pill)
            }
        }
        store.pushLocalChangesToBeSaved(pills)
    }

    // MARK: - Public

    public func at(_ index: Index) -> Swallowable? {
        pills.tryGet(at: index)
    }

    public func get(by id: UUID) -> Swallowable? {
        pills.first(where: { p in p.id == id })
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        if let pill = at(index) {
            set(for: pill, with: attributes)  // Saves
            broadcastData()
        }
    }

    public func set(for pill: Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        store.pushLocalChangesToBeSaved(pill)
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
            store.pushLocalChangesToBeSaved(pill)
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
    
    public func broadcastData() {
        if let next = nextDue {
            meter.broadcastRelevantPillData(nextPill: next)
        }
    }
    
    // MARK: - Private

    private func awaken() {
        for pill in pills {
            pill.awaken()
        }
        store.pushLocalChangesToBeSaved(pills)
    }
    
    private func deleteAll() {
        pills.forEach { (_ p: Swallowable) -> () in store.delete(p) }
        pills = []
    }
}
