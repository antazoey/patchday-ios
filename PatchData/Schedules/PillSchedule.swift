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

public class PillSchedule: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOPill array."
    }
    
    public var pillArray: [MOPill]
    private var pillMap = [UUID: MOPill]()

    override init() {
        pillArray = PillSchedule.loadPillMOs(into: PatchData.getContext())
        PillSchedule.loadTakenTodays(for: pillArray, into: PatchData.getContext())
        pillArray = pillArray.filter() {
            $0.getName() != nil
        }
        PillSchedule.loadMap(pillMap: &pillMap, pillArray: pillArray)
    }
    
    // MARK: - Public
    
    public func getPills() -> [MOPill] {
        return pillArray
    }

    /// Returns the MOPill for the given index.
    public func getPill(at index: Index) -> MOPill? {
        if index >= 0 && index < pillArray.count {
            return pillArray[index]
        }
        return nil
    }
    
    /// Returns the MOPill for the given ID.
    public func getPill(for id: UUID) -> MOPill? {
        return pillMap[id]
    }
    
    /// Creates a new MOPill and inserts it in to the pillArray.
    public func insertNewPill() -> MOPill? {
        let newPillAttributes = PillAttributes()
        let newPill = PillSchedule.appendNewPill(to: &pillArray, andTo: &pillMap, using: newPillAttributes, into: PatchData.getContext())
        TodayData.setPillDataForToday()
        return newPill
    }
    
    /// Sets a given MOPill with the given PillAttributes.
    public static func setPillAttributes(for pill: MOPill, with attributes: PillAttributes) {
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
        pill.setID()
        PatchData.save()
    }
    
    /// Sets the second time for the pill at the given index.
    public func setPillTime2(at index: Index, to newTime: Time) {
        if let pill = getPill(at: index) {
            pill.setTime2(with: newTime as NSDate)
            PatchData.save()
        }
    }
    
    /// Deletes the pill at the given index from the schedule.
    public func deletePill(at index: Index) {
        if index >= 0 && index < pillArray.count {
            pillArray[index].reset()
        }
        pillArray = pillArray.filter() { $0.getName() != nil}
        PatchData.save()
    }
    
    /// Maps MOPills to their last time takens.
    public func getPillTimesTakens() -> [Int] {
        return pillArray.map({
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
    public func takePill(at index: Index) {
        if let pill = getPill(at: index) {
            pill.take()
            PatchData.save()
            // Reflect in Today widget
            TodayData.setPillDataForToday()
        }
    }
    
    /// Sets the given pill's last date taken to now, and increments how many times it was taken today.
    public func take(_ pill: MOPill) {
        pill.take()
        PatchData.save()
        // Reflect in the Today widget
        TodayData.setPillDataForToday()
    }
    
    /// Returns the next pill that needs to be taken.
    public func nextPillDue() -> MOPill? {
        return pillArray.min(by: <)
    }
    
    // MARK: - Private
    
    /// For bringing persisted MOPills into memory when starting the app.
    private static func loadPillMOs(into context: NSManagedObjectContext) -> [MOPill] {
        let fetchRequest = NSFetchRequest<MOPill>(entityName: PDStrings.CoreDataKeys.pillEntityName)
        fetchRequest.propertiesToFetch = PDStrings.CoreDataKeys.pillPropertyNames
        do {
            let pills = try context.fetch(fetchRequest)
            initIDs(for: pills, into: context)
            return pills
        }
        catch {
            print("Data Fetch Request Failed")
        }
        return []
    }
    
    /// Generates a generic list of MOPills when there are none in store.
    public static func newPillMOs(into context: NSManagedObjectContext) -> [MOPill] {
        var generatedPillMOs: [MOPill] = []
        var names = PDStrings.PillTypes.defaultPills
        for i in 0..<names.count {
            if let pill = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
                pill.initAttributes(name: names[i])
                generatedPillMOs.append(pill)
            }
        }
        PatchData.save()
        return generatedPillMOs
    }
    
    /// Sets the pillArray and map to a generic list of MOPills.
    public func makeNewDefaultPillMOs() {
        pillArray = PillSchedule.newPillMOs(into: PatchData.getContext())
        PDSchedule.pillSchedule.loadMap()
    }
    
    /// Initializes IDs for the given pills.
    private static func initIDs(for pills: [MOPill], into context: NSManagedObjectContext) {
        for pill in pills {
            pill.setID()
        }
        PatchData.save()
    }
    
    /// Resets "taken today" if it is a new day. Else, does nothing.
    private static func loadTakenTodays(for pills: [MOPill], into context: NSManagedObjectContext) {
        for pill in pills {
            pill.fixTakenToday()
        }
        PatchData.save()
    }
    
    /// Creates a new Pill with the given attributes and appends it to the schedule.
    private static func appendNewPill(to pills: inout [MOPill], andTo pillMap: inout [UUID: MOPill], using attributes: PillAttributes, into context: NSManagedObjectContext) -> MOPill? {
        if let pill = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
            setPillAttributes(for: pill, with: attributes)
            pills.append(pill)
            pillMap[pill.getID()] = pill
            return pill
        }
        return nil
    }
    
    /// Load estrogen ID map after changes occur to the schedule.
    public static func loadMap(pillMap: inout [UUID: MOPill], pillArray: [MOPill]) {
        pillMap = pillArray.reduce([UUID: MOPill]()) {
            (pillDict, pill) -> [UUID: MOPill] in
            var dict = pillDict
            dict[pill.getID()] = pill
            return dict
        }
    }
    
    public func loadMap() {
        PillSchedule.loadMap(pillMap: &pillMap, pillArray: pillArray)
    }
}
