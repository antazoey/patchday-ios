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

public class PillDataController: NSObject {
    
    override public var description: String {
        return "PillDataController is a sub-controller for the ScheduleController used to manage the array of MOPills."
    }
    
    internal var pillArray: [MOPill]
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override init() {
        pillArray = PillDataController.loadPillMOs(into: ScheduleController.getContext())
        PillDataController.loadTakenTodays(for: pillArray, into: ScheduleController.getContext())
        pillArray = pillArray.filter() {
            $0.getName() != nil
        }
    }
    
    // MARK: - Public
    
    internal func getPill(for name: String) -> MOPill? {
        if let i = pillArray.map({
            (pill: MOPill) -> String? in
            return pill.getName()
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
        let newPill = PillDataController.appendNewPill(to: &pillArray, using: newPillAttributes, into: ScheduleController.getContext())
        ScheduleController.setPillDataForToday()
        return newPill
    }
    
    /// Sets a given MOPill with the given PillAttributes.
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
        if let id = attributes.id {
            pill.setID(with: id)
        }
        ScheduleController.save()
    }
    
    internal func setPillTime2(at index: Index, to newTime: Time) {
        if let pill = getPill(at: index) {
            pill.setTime2(with: newTime as NSDate)
            ScheduleController.save()
        }
    }
    
    internal func deletePill(at index: Index) {
        if index >= 0 && index < pillArray.count {
            pillArray[index].reset()
        }
        pillArray = pillArray.filter() { $0.getName() != nil}
        ScheduleController.save()
    }
    
    /// Maps MOPills to their last time takens.
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
    
    internal func takePill(at index: Index) {
        if let pill = getPill(at: index) {
            pill.take()
            ScheduleController.save()
            appDelegate.notificationsController.requestNotifyTakePill(pill)
            ScheduleController.setPillDataForToday()
        }
    }
    
    internal func take(_ pill: MOPill) {
        pill.take()
        ScheduleController.save()
        appDelegate.notificationsController.requestNotifyTakePill(pill)
        ScheduleController.setPillDataForToday()
    }
    
    internal func nextPillDue() -> MOPill? {
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
    
    /// Generates a generic list of MOSites when there are none in store.
    public static func newPillMOs(into context: NSManagedObjectContext) -> [MOPill] {
        var generatedPillMOs: [MOPill] = []
        var names = PDStrings.PillTypes.defaultPills
        for i in 0..<names.count {
            if let pill = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
                pill.initAttributes(name: names[i])
                generatedPillMOs.append(pill)
            }
        }
        ScheduleController.save()
        return generatedPillMOs
    }
    
    private static func initIDs(for pills: [MOPill], into context: NSManagedObjectContext) {
        for pill in pills {
            if pill.getID() == nil {
                pill.setID(with: UUID())
            }
        }
        ScheduleController.save()
    }
    
    private static func loadTakenTodays(for pills: [MOPill], into context: NSManagedObjectContext) {
        for pill in pills {
            pill.fixTakenToday()
        }
        ScheduleController.save()
    }
    
    /// Creates a new Pill with the given attributes and appends it to the schedule.
    private static func appendNewPill(to pills: inout [MOPill], using attributes: PillAttributes, into context: NSManagedObjectContext) -> MOPill? {
        if let pill = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.pillEntityName, into: context) as? MOPill {
            setPillAttributes(for: pill, with: attributes)
            pills.append(pill)
            return pill
        }
        return nil
    }
}
