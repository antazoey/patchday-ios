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
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOPill array."
    }
    
    private var pills: [Swallowable]
    
    override init() {
        pills = PatchData.createPills()
        super.init()
        awaken()
    }
    
    public var all: [Swallowable] { return pills }
    
    public var count: Int { return pills.count }
    
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

    /// Creates a new MOPill and inserts it in to the pills.
    public func insert(completion: (() -> ())?) -> Swallowable? {
        if let pill = PDPill.new() {
            pill.initializeAttributes(attributes: PillAttributes())
            pills.append(pill)
            if let comp = completion {
                comp()
            }
            return pill
        }
        return nil
    }
    
    /// Deletes the pill at the given index from the schedule.
    public func delete(at index: Index) {
        switch index {
        case 0..<pills.count :
            let pill = pills.remove(at: index)
            pill.delete()
            PatchData.save()
        default : return
        }
    }
    
    /// Generates a generic list of MOPills when there are none in store.
    public func new() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = PatchData.insert(.pill) as? MOPill {
                pills.append(PDPill(pill: pill, name: names[i]))
            }
        }
        PatchData.save()
    }

    // MARK: - Public

    /// Returns the MOPill for the given index.
    public func at(_ index: Index) -> Swallowable? {
        if index >= 0 && index < pills.count {
            return pills[index]
        }
        return nil
    }
    
    /// Returns the MOPill for the given Id.
    public func get(for id: UUID) -> Swallowable? {
        for pill in pills {
            if pill.id == id {
                return pill
            }
        }
        return nil
    }
    
    /// Sets a given MOPill with the given PillAttributes.
    public func set(at index: Index, with attributes: PillAttributes) {
        if let pill = at(index) {
            set(for: pill, with: attributes)
        }
    }
    
    /// Sets a given MOPill with the given PillAttributes.
    public func set(for pill: Swallowable, with attributes: PillAttributes) {
        pill.initializeAttributes(attributes: attributes)
        PatchData.save()
    }
    
    /** Sets the pill's last date-taken at the given index to now,
    and increments how many times it was taken today. */
    public func swallow(at index: Index, pushSharedData: (() -> ())?) {
        if let pill = at(index) {
            swallow(pill, pushSharedData: pushSharedData)
        }
    }
    
    /** Sets the given pill's last date taken to now,
    and increments how many times it was taken today. */
    public func swallow(_ pill: Swallowable, pushSharedData: (() -> ())?) {
        if pill.timesTakenToday < pill.timesaday {
            pill.swallow()
            PatchData.save()
            // Reflect in the Today widget
            if let setData = pushSharedData {
                setData()
            }
        }
    }
    
    /// Takes the pills that is next due.
    public func swallow(pushSharedData: (() -> ())? = nil) {
        if let next = nextDue {
            swallow(next, pushSharedData: pushSharedData)
        }
    }
    
    // MARK: - Private

    /// Resets "taken today" if it is a new day. Else, does nothing.
    private func awaken() {
        for pill in pills {
            pill.awaken()
        }
        PatchData.save()
    }
    
    private func deleteAll() {
        for pill in pills { pill.delete() }
        pills = []
    }
}
