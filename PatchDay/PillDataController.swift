//
//  PillDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PillDataController {
    
    internal var pillArray: [MOPill]
    internal let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        pillArray = PillDataController.loadPillMOs(into: context)
        PillDataController.loadTakenTodays(for: pillArray, into: context)
        pillArray = pillArray.filter() {
            $0.getName() != nil
        }
        if pillArray.count == 0 {
            pillArray = PillDataController.newPillMOs(into: context)
        }
        pillArray.sort(by: <)
    }
    
    // MARK: - Public
    
    internal func getPill(for name: String) -> MOPill? {
        if let i = pillArray.map({
            (value: MOPill) -> String? in
            return value.getName()
        }).index(of: name) {
            return pillArray[i]
        }
        return nil
    }
    
    internal func getPill(at index: Index) -> MOPill? {
        if index >= 0 && index < pillArray.count {
            return pillArray[index]
        }
        return nil
    }
    
    public func insertNewPill() -> MOPill? {
        let newPillAttributes = PillAttributes()
        let newPill = PillDataController.appendPill(to: &pillArray, attributes: newPillAttributes, into: context)
        return newPill
    }
    
    // Set's a given MOPill with the given PillAttributes.
    internal static func setPillAttributes(for pill: MOPill, with attributes: PillAttributes) {
        
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
        PillDataController.saveContext(ScheduleController.persistentContainer.viewContext)
    }
    
    internal func setPillTime2(at index: Index, to newTime: Time) {
        if let pill = getPill(at: index) {
            pill.setTime2(with: newTime as NSDate)
            PillDataController.saveContext(ScheduleController.persistentContainer.viewContext)
        }
    }
    
    internal func deletePill(at index: Index) {
        if index >= 0 && index < pillArray.count {
            pillArray[index].reset()
        }
        pillArray = pillArray.filter() { $0.getName() != nil}
        pillArray.sort(by: <)
        PillDataController.saveContext(ScheduleController.persistentContainer.viewContext)
    }
    
    // Maps MOPills to their last time takens.
    internal func getPillTimesTakens() -> [Int] {
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
    
    // Maps MOPills to their next relevant due times.
    internal func getNextPillDueDates() -> [Date] {
        return pillArray.map({
            (pill: MOPill) -> Time? in
            return pill.getDueDate()
        }).filter() {
            $0 != nil
            }.map({
                (time: Time?) -> Time in
                return time!
            })
    }
    
    internal func takePill(at index: Index) {
        if let pill = getPill(at: index) {
            pill.take()
            pillArray.sort(by: <)
            PillDataController.saveContext(context)
        }
    }
    
    // MARK: - Private
    
    // For bringing persisted MOPills into memory when starting the app.
    private static func loadPillMOs(into context: NSManagedObjectContext) -> [MOPill] {
        let fetchRequest = NSFetchRequest<MOPill>(entityName: PDStrings.CoreDataKeys.pillEntityName)
        fetchRequest.propertiesToFetch = PDStrings.CoreDataKeys.pillPropertyNames
        do {
            return try context.fetch(fetchRequest)
        }
        catch {
            print("Data Fetch Request Failed")
        }
        return []
    }
    
    // Generates a generic list of MOSites when there are none in store.
    private static func newPillMOs(into context: NSManagedObjectContext) -> [MOPill] {
        var generatedPillMOs: [MOPill] = []
        var names = PDStrings.PillTypes.defaultPills
        for i in 0...(names.count-1) {
            if let pillmo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
                pillmo.setName(with: names[i])
                pillmo.setTimesaday(with: 1)
                pillmo.setTime1(with: NSDate())
                pillmo.setTime2(with: NSDate())
                pillmo.setNotify(with: true)
                pillmo.setTimesTakenToday(with: 0)
                generatedPillMOs.append(pillmo)
            }
        }
        saveContext(context)
        return generatedPillMOs
    }
    
    private static func loadTakenTodays(for pills: [MOPill], into context: NSManagedObjectContext) {
        for pill in pills {
            pill.fixTakenToday()
        }
        saveContext(context)
    }
    
    // Creates a new Pill with the given attributes and appends it to the schedule.
    private static func appendPill(to pills: inout [MOPill], attributes: PillAttributes, into context: NSManagedObjectContext) -> MOPill? {
        if let pill = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
            setPillAttributes(for: pill, with: attributes)
            pills.append(pill)
            return pill
        }
        return nil
    }
    
    internal static func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                PDAlertController.alertForCoreDataError()
            }
        }
    }
    
}
