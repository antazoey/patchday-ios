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
    
    private var pills: [Swallowable]
    private let store: PDCoreDataDelegate
    private let meter: DataShareDelegate
    
    enum PillScheduleState {
        case Initial
        case Working
    }
    
    init(store: PDCoreDataDelegate, pillDataMeter: DataShareDelegate, state: PillScheduleState) {
        self.store = store
        self.meter = pillDataMeter
        self.pills = store.createPills()
        super.init()
        if state == .Initial {
            self.reset()
        }
        awaken()
    }
    
    public var all: [Swallowable] { pills }

    public var count: Int { pills.count }
    
    public var nextDue: Swallowable? {
        if let pills = pills as? [Pill] {
            return pills.min(by: <)
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
            if let comp = completion {
                comp()
            }
            meter.broadcastRelevantPillData(nextPill: pill)
            store.save()
            return pill
        }
        return nil
    }

    public func delete(at index: Index) {
        if let pill = at(index) {
            pill.delete()
            meter.broadcastRelevantPillData(nextPill: pill)
            store.save()
        }
    }

    public func reset() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = store.createNewPill(named: names[i]) {
                pills.append(pill)
            }
        }
        store.save()
    }

    // MARK: - Public

    public func at(_ index: Index) -> Swallowable? {
        pills.tryGet(at: index)
    }

    public func get(for id: UUID) -> Swallowable? {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            return at(index)
        }
        return nil
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        if let pill = at(index) {
            set(for: pill, with: attributes)  // Saves
            meter.broadcastRelevantPillData(nextPill: pill)
        }
    }

    public func set(for pill: Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        store.save()
    }

    public func swallow(at index: Index, completion: (() -> ())?) {
        if let pill = at(index) {
            swallow(pill, completion: completion) // Saves
        }
    }

    public func swallow(_ pill: Swallowable, completion: (() -> ())?) {
        swallow(pill) // Saves
        if let comp = completion {
            comp()
        }
    }

    public func swallow(_ pill: Swallowable) {
        if pill.timesTakenToday < pill.timesaday {
            pill.swallow()
            store.save()
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
        store.save()
    }
    
    private func deleteAll() {
        pills.forEach { (_ p: Swallowable) -> () in p.delete() }
        pills = []
    }
}
