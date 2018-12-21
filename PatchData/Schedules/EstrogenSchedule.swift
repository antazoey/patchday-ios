//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class EstrogenSchedule: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOEstrogen array."
    }
    
    public var estrogenArray: [MOEstrogen]
    private var estrogenMap = [UUID: MOEstrogen]()
    private var effectManager = ScheduleChangeManager()
    
    override init() {
        let context = PatchData.getContext()
        estrogenArray = []
        // Load previously saved MOEstrogens
        if let estros = EstrogenSchedule.loadEstrogenMOs(from: context) {
            estrogenArray = estros
        }
            // New MOEstrogens if all else fails
        else {
            estrogenArray = EstrogenSchedule.newEstrogenMOs(from: context)
        }
        estrogenArray.sort(by: <)
        EstrogenSchedule.loadMap(estroMap: &estrogenMap, estroArray: estrogenArray)

    }
    
    // MARK: - Public
    
    public func getEstrogens() -> [MOEstrogen] {
        return estrogenArray
    }
    
    public func getEffectManager() -> ScheduleChangeManager {
        return effectManager
    }
    
    public func deleteExtra(after count: Int) {
        let c = estrogenArray.count
        if c > count {
            for i in count..<c {
                if i < estrogenArray.count {
                    PatchData.getContext().delete(estrogenArray[i])
                }
            }
        }
        PatchData.save()
    }
    
    /// Returns the MOEstrogen for the given index or creates one where one should be.
    public func getEstrogen(at index: Index) -> MOEstrogen {
        if index >= 0, index < estrogenArray.count {
            return estrogenArray[index]
        }
        let newEstro = newEstrogenMOForSchedule(in: PatchData.getContext())
        return newEstro
    }
    
    /// Returns the MOEstrogen for the given index if it exists.
    public func getEstrogenOptional(at index: Index) -> MOEstrogen? {
        if index >= 0, index < estrogenArray.count {
            return estrogenArray[index]
        }
        return nil
    }
    
    /// Returns the MOEstrogen for the given id.
    public func getEstrogen(for id: UUID) -> MOEstrogen? {
        return estrogenMap[id]
    }
    
    /// Sets the site of the MOEstrogen for the given index.
    public func setEstrogenSite(of index: Index, with site: MOSite) {
        let estro = getEstrogen(at: index)
        estro.setSite(with: site)
        TodayData.setEstrogenDataForToday()
        PatchData.save()
    }
    
    /// Sets the date of the MOEstrogen for the given index.
    public func setEstrogenDate(of index: Index, with date: Date) {
        let estro = getEstrogen(at: index)
        estro.setDate(with: date as NSDate)
        estrogenArray.sort(by: <)
        TodayData.setEstrogenDataForToday()
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, date: NSDate, site: MOSite) {
        let estro = getEstrogen(at: index)
        estro.setSite(with: site)
        estro.setDate(with: date)
        estrogenArray.sort(by: <)
        TodayData.setEstrogenDataForToday()
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given id.
    public func setEstrogen(for id: UUID, date: NSDate, site: MOSite) {
        if let estro = getEstrogen(for: id) {
            estro.setSite(with: site)
            estro.setDate(with: date)
            estrogenArray.sort(by: <)
            TodayData.setEstrogenDataForToday()
            PatchData.save()
        }
    }
    
    /// Sets the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, with estrogen: MOEstrogen) {
        if index < estrogenArray.count && index >= 0 {
            estrogenArray[index] = estrogen
            estrogenArray.sort(by: <)
            TodayData.setEstrogenDataForToday()
            PatchData.save()
        }
    }
    
    /// Sets the backup-site-name of the MOEstrogen for the given index.
    public func setEstrogenBackUpSiteName(of index: Index, with name: String) {
        if index < estrogenArray.count && index >= 0 {
            estrogenArray[index].setSiteBackup(to: name)
        }
    }
    
    /// Returns the index of the given estrogen.
    public func getEstrogenIndex(for estrogen: MOEstrogen) -> Index? {
        return estrogenArray.index(of: estrogen)
    }
    
    /// Returns the next MOEstrogen that needs to be taken.
    public func nextEstroDue() -> MOEstrogen? {
        estrogenArray.sort(by: <)
        if estrogenArray.count > 0 {
            return estrogenArray[0]
        }
        return nil
    }
    
    /// Returns the total non-nil dates in given estrogens.
    public func datePlacedCount() -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.date != nil) ? 1 : 0
            return c + count
        })
    }
    
    /// Sets all MOEstrogen data to nil.
    public func resetEstrogenData() {
        let context = PatchData.getContext()
        for estro in estrogenArray {
            estro.reset()
            context.delete(estro)
        }
        estrogenArray = []
        PatchData.save()
    }
    
    /// Sets all MOEstrogen data between given indices to nil.
    public func resetEstrogenData(start_i: Index, end_i: Index) {
        let context = PatchData.getContext()
        for i in start_i...end_i {
            if i < estrogenArray.count {
                estrogenArray[i].reset()
                context.delete(estrogenArray[i])
            }
        }
        estrogenArray = Array(estrogenArray.prefix(start_i))
        PatchData.save()
    }
    
    /// Returns if there are no dates in the estrogen schedule.
    public func hasNoDates() -> Bool {
        return (estrogenArray.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    /// Returns if there are no sites in the estrogen schedule.
    public func hasNoSites() -> Bool {
        return (estrogenArray.filter() {
            $0.getSite() != nil
        }).count == 0
    }
    
    /// Returns if there are no dates or sites in the estrogen schedule.
    public func isEmpty() -> Bool {
        return hasNoDates() && hasNoSites()
    }
    
    /// Returns if each MOEstrogen fromThisIndexOnward is empty.
    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if i >= 0 && i < estrogenArray.count {
                    let estro = estrogenArray[i]
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// Returns how many expired estrogens there are in the given estrogens.
    public func expiredCount(_ intervalStr: String) -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.isExpired(intervalStr)) ? 1 : 0
            return c + count
        })
    }
    
    // MARK: - Private
    
    /// Brings persisted MOEstrogens into memory when starting the app.
    private static func loadEstrogenMOs(from context: NSManagedObjectContext) -> [MOEstrogen]? {
        let fetchRequest = NSFetchRequest<MOEstrogen>(entityName: PDStrings.CoreDataKeys.estroEntityName)
        fetchRequest.propertiesToFetch = PDStrings.CoreDataKeys.estroPropertyNames()
        do {
            // Load user data if it exists
            let userMOs = try context.fetch(fetchRequest)
            if userMOs.count > 0 {
                return userMOs
            }
        }
        catch {
            // Calling function inits new Estro MOs if we get here.
            print("Data Fetch Request Failed")
        }
        return nil
    }
    
    /// Initializes generic MOEstrogens.
    private static func newEstrogenMOs(from context: NSManagedObjectContext) -> [MOEstrogen] {
        let entityName = PDStrings.CoreDataKeys.estroEntityName
        var estros: [MOEstrogen] = []
        for _ in 0..<PDStrings.PickerData.counts.count {
            if let estro = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? MOEstrogen {
                estros.append(estro)
            }
            else {
                PatchDataAlert.alertForCoreDataError()
                estros.append(MOEstrogen())
            }
        }
        initIDs(for: estros)
        return estros
    }
    
    /// Statically create a new MOEstrogen. Does not append to estrogenArray.
    private static func newEstrogenMO(in context: NSManagedObjectContext) -> MOEstrogen {
        let entityName = PDStrings.CoreDataKeys.estroEntityName
        if let estro = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? MOEstrogen {
            initID(for: estro)
            return estro
        }
        else {
            let estro = MOEstrogen()
            initID(for: estro)
            return estro
        }
    }
    
    /// Creates a new MOEstrogen and appends it to the estrogenArray.
    private func newEstrogenMOForSchedule(in context: NSManagedObjectContext) -> MOEstrogen {
        let newEstro = EstrogenSchedule.newEstrogenMO(in: context)
        estrogenArray.append(newEstro)
        estrogenMap[newEstro.getID()] = newEstro
        estrogenArray.sort(by: <)
        EstrogenSchedule.initID(for: newEstro)
        return newEstro
    }
    
    /// Set UUId for estro.
    private static func initID(for estro: MOEstrogen) {
        estro.setID()
    }
    
    /// Sets UUID for estros if there is none.
    private static func initIDs(for estros: [MOEstrogen]) {
        for estro in estros {
            estro.setID()
        }
    }
    
    /// Load estrogen ID map after changes occur to the schedule.
    public static func loadMap(estroMap: inout [UUID: MOEstrogen], estroArray: [MOEstrogen]) {
        estroMap = estroArray.reduce([UUID: MOEstrogen]()) {
            (estroDict, estro) -> [UUID: MOEstrogen] in
            var dict = estroDict
            dict[estro.getID()] = estro
            return dict
        }
    }
    
    private func loadMap() {
        EstrogenSchedule.loadMap(estroMap: &estrogenMap, estroArray: estrogenArray)
        
    }
    
    public func printEstrogens() {
        print("\n")
        for estro in estrogenArray {
            print("Estrogen")
            if let d = estro.getDate() {
                print(PDDateHelper.format(date: d as Date, useWords: true))
            }
            if let s = estro.getSite(), let n = s.getName() {
                print(n)
            }
            else if let n = estro.getSiteNameBackUp() {
                print(n)
            }
            print("---")
        }
    }
    
}
