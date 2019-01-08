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

public class PillSchedule: PDScheduleProtocol {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOPill array."
    }
    
    public var pills: [MOPill] = []
    private var pillMap = [UUID: MOPill]()
    
    init() {
        super.init(type: .pill)
        pills = mos as! [MOPill]
        mos = []
        loadTakenTodays(for: pills)
        filterEmpty()
        loadMap()
    }
    
    // MARK: - Override base class
    
    override public func count() -> Int {
        return pills.count
    }

    /// Creates a new MOPill and inserts it in to the pills.
    override public func insert(completion: (() -> ())?) -> MOPill? {
        let attributes = PillAttributes()
        let pill = append(using: attributes)
        //PDSharedData.setPillDataForToday()
        if let comp = completion {
            comp()
        }
        return pill
    }
    
    /// Sets the pills and map to a generic list of MOPills.
    override public func reset(completion: (() -> ())? = nil) {
        new()
        pillMap.removeAll()
        loadMap()
        if let comp = completion {
            comp()
        }
    }
    
    /// Generates a generic list of MOPills when there are none in store.
    override public func new() {
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = PatchData.insert(type.rawValue) as? MOPill {
                pill.initAttributes(name: names[i])
                pills.append(pill)
            }
        }
        PatchData.save()
    }
    
    override public func filterEmpty() {
        pills = pills.filter() { $0.getName() != nil }
    }
    
    // MARK: - Public

    /// Returns the MOPill for the given index.
    public func getPill(at index: Index) -> MOPill? {
        if index >= 0 && index < pills.count {
            return pills[index]
        }
        return nil
    }
    
    /// Returns the MOPill for the given Id.
    public func getPill(for id: UUID) -> MOPill? {
        return pillMap[id]
    }
    
    /// Sets a given MOPill with the given PillAttributes.
    public func setPill(at index: Index, with attributes: PillAttributes) {
        if let pill = getPill(at: index) {
            setPill(for: pill, with: attributes)
        }
    }
    
    /// Sets a given MOPill with the given PillAttributes.
    public func setPill(for pill: MOPill, with attributes: PillAttributes) {
        if let name = attributes.name {
            pill.setName(with: name)
        }
        if let timesaday = attributes.timesaday {
            pill.setTimesaday(with: Int16(timesaday))
        }
        if let t1 = attributes.time1 {
            pill.setTime1(with: t1 as NSDate)
        }
        if let t2 = attributes.time2 {
            pill.setTime2(with: t2 as NSDate)
        }
        if let notify = attributes.notify {
            pill.setNotify(with: notify)
        }
        if let timesTakenToday = attributes.timesTakenToday {
            pill.setTimesTakenToday(with: Int16(timesTakenToday))
        }
        if let lastTaken = attributes.lastTaken {
            pill.setLastTaken(with: lastTaken as NSDate)
        }
        PatchData.save()
    }
    
    /// Deletes the pill at the given index from the schedule.
    public func deletePill(at index: Index) {
        if index >= 0 && index < pills.count {
            pills[index].reset()
        }
        filterEmpty()
        PatchData.save()
    }
    
    /// Maps MOPills to their last time takens.
    public func getPillTimesTakens() -> [Int] {
        return pills.map({
            (pill: MOPill) -> Int16? in
            return pill.getTimesTakenToday()
        }).filter() {
            $0 != nil
            }.map({
                (takenCount: Int16?) -> Int in
                return Int(takenCount!)
            })
    }
    
    /// Sets the pill's last date-taken at the given index to now, and increments how many times it was taken today.
    public func takePill(at index: Index, setPDSharedData: (() -> ())?) {
        if let pill = getPill(at: index) {
            pill.take()
            PatchData.save()
            // Reflect in Today widget
            if let setToday = setPDSharedData {
                setToday()
            }
        }
    }
    
    /// Sets the given pill's last date taken to now, and increments how many times it was taken today.
    public func take(_ pill: MOPill, setPDSharedData: (() -> ())?) {
        pill.take()
        PatchData.save()
        // Reflect in the Today widget
        if let setToday = setPDSharedData {
            setToday()
        }
    }
    
    /// Returns the next pill that needs to be taken.
    public func nextPillDue() -> MOPill? {
        return pills.min(by: <)
    }
    
    public func printPills() {
        for pill in pills {
            print(pill)
        }
    }
    
    public func totalDue() -> Int {
        return pills.reduce(0, {
            (count: Int, pill: MOPill) -> Int in
            let r = pill.isExpired() ? 1 + count : count
            return r
        })
    }
    
    // MARK: - Private

    /// Resets "taken today" if it is a new day. Else, does nothing.
    private func loadTakenTodays(for pills: [MOPill]) {
        for pill in pills {
            pill.fixTakenToday()
        }
        PatchData.save()
    }
    
    /// Creates a new Pill with the given attributes and appends it to the schedule.
    private func append(using attributes: PillAttributes) -> MOPill? {
        if let pill = PatchData.insert(type.rawValue) as? MOPill {
            setPill(for: pill, with: attributes)
            pills.append(pill)
            loadMap()
            return pill
        }
        return nil
    }

    /// Load estrogen Id map after changes occur to the schedule.
    private func loadMap() {
        pillMap.removeAll()
        pillMap = pills.reduce([UUID: MOPill]()) {
            (pillDict, pill) -> [UUID: MOPill] in
            var dict = pillDict
            if let id = pill.getId() {
                dict[id] = pill
            } else {
                let id = pill.setId()
                dict[id] = pill
            }
            return dict
        }
    }
}
