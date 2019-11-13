//
//  PillSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PDPills: NSObject, PDPillScheduling {
    
    override public var description: String { "Schedule for pills." }
    
    private var pills: [Swallowable]
    private let store: PatchDataCalling
    private let meter: PDDataMeting
    
    init(store: PatchDataCalling, pillDataMeter: PDDataMeting, isFirstInit: Bool) {
        self.store = store
        self.meter = pillDataMeter
        self.pills = store.createPills()
        super.init()
        if isFirstInit { self.reset() }
        awaken()
    }
    
    public var all: [Swallowable] { pills }

    public var count: Int { pills.count }
    
    public var nextDue: Swallowable? {
        if let pills = pills as? [PDPill] {
            return pills.min(by: <)
        }
        return nil
    }

    public var totalDue: Int {
        return pills.reduce(0, {
            (count: Int, pill: Swallowable) -> Int in
            let r = pill.isDue ? 1 + count : count
            return r
        })
    }
    
    // MARK: - Override base class

    public func insertNew(completion: (() -> ())?) -> Swallowable? {
        if let pill = PDPill.new() {
            pills.append(pill)
            if let comp = completion {
                comp()
            }
            meter.broadcastRelevantPillData(nextPill: pill)
            return pill
        }
        return nil
    }

    public func delete(at index: Index) {
        if let pill = at(index) {
            pill.delete()
            store.save()
            meter.broadcastRelevantPillData(nextPill: pill)
        }
    }

    public func reset() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = store.createPill(named: names[i]) {
                pills.append(pill)
            }
        }
        store.save()
    }

    // MARK: - Public

    public func at(_ index: Index) -> Swallowable? {
        return pills.tryGet(at: index)
    }

    public func get(for id: UUID) -> Swallowable? {
        for pill in pills {
            if pill.id == id {
                return pill
            }
        }
        return nil
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        if let pill = at(index) {
            set(for: pill, with: attributes)
            meter.broadcastRelevantPillData(nextPill: pill)
        }
    }

    public func set(for pill: Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        store.save()
    }

    public func swallow(at index: Index, completion: (() -> ())?) {
        if let pill = at(index) {
            swallow(pill, completion: completion)
        }
    }

    public func swallow(_ pill: Swallowable, completion: (() -> ())?) {
        if pill.timesTakenToday < pill.timesaday {
            pill.swallow()
            store.save()
            if let comp = completion {
                comp()
            }
        }
    }

    public func swallow(completion: (() -> ())? = nil) {
        if let next = nextDue {
            swallow(next, completion: completion)
        }
    }
    
    public func indexOf(_ pill: Swallowable) -> Index? {
        return pills.firstIndex { (_ p: Swallowable) ->
            Bool in
            pill.id == p.id
        }
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
        for pill in pills { pill.delete() }
        pills = []
    }
}
