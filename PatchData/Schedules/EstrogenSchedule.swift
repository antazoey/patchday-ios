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

public typealias Index = Int;

public class EstrogenSchedule: PDScheduleProtocol {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOEstrogen array."
    }
    
    public var estrogens: [MOEstrogen]
    private var estrogenMap = [UUID: MOEstrogen]()
    private var effectManager = ScheduleChangeManager()
    
    override init() {
        estrogens = []
        // Load previously saved MOEstrogens
        if let estros = PatchData.loadMOs(for: .estrogen) as? [MOEstrogen] {
            estrogens = estros
        } else {
            // Create new estrogens
            let c = PDStrings.PickerData.counts.count
            estrogens = EstrogenSchedule.new(count: c)
        }
        estrogens.sort(by: <)
        EstrogenSchedule.loadMap(estroMap: &estrogenMap, estroArray: estrogens)
    }
    
    // MARK: - Base class overrides
    
    override public func count() -> Int {
        return estrogens.count
    }
    
    /// Creates a new MOEstrogen and appends it to the estrogens.
    override public func insert() -> MOEstrogen {
        let estro = EstrogenSchedule.new(count: 1)[0]
        estrogens.append(estro)
        estrogenMap[estro.getID()] = estro
        estrogens.sort(by: <)
        EstrogenSchedule.initID(for: estro)
        return estro
    }
    
    /// Sets all MOEstrogen data to nil.
    override public func reset() {
        let context = PatchData.getContext()
        for estro in estrogens {
            estro.reset()
            context.delete(estro)
        }
        estrogens = []
        PatchData.save()
    }
    
    // MARK: - Public
    
    public func getEstrogens() -> [MOEstrogen] {
        return estrogens
    }
    
    public func getEffectManager() -> ScheduleChangeManager {
        return effectManager
    }
    
    public func delete(after i: Index) {
        let c = count()
        if c > i {
            for j in i..<c {
                PatchData.getContext().delete(estrogens[j])
            }
            PatchData.save()
        }
    }
    
    /// Returns the MOEstrogen for the given index or creates one where one should be.
    public func getEstrogen(at index: Index) -> MOEstrogen {
        if index >= 0, index < count() {
            return estrogens[index]
        }
        return insert()
    }
    
    /// Returns the MOEstrogen for the given index if it exists.
    public func getEstrogenOptional(at index: Index) -> MOEstrogen? {
        if index >= 0, index < count() {
            return estrogens[index]
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
        estrogens.sort(by: <)
        TodayData.setEstrogenDataForToday()
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, date: NSDate, site: MOSite) {
        let estro = getEstrogen(at: index)
        estro.setSite(with: site)
        estro.setDate(with: date)
        estrogens.sort(by: <)
        TodayData.setEstrogenDataForToday()
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given id.
    public func setEstrogen(for id: UUID, date: NSDate, site: MOSite) {
        if let estro = getEstrogen(for: id) {
            estro.setSite(with: site)
            estro.setDate(with: date)
            estrogens.sort(by: <)
            TodayData.setEstrogenDataForToday()
            PatchData.save()
        }
    }
    
    /// Sets the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, with estrogen: MOEstrogen) {
        if index < count() && index >= 0 {
            estrogens[index] = estrogen
            estrogens.sort(by: <)
            TodayData.setEstrogenDataForToday()
            PatchData.save()
        }
    }
    
    /// Sets the backup-site-name of the MOEstrogen for the given index.
    public func setBackUpSiteName(of index: Index, with name: String) {
        if index < count() && index >= 0 {
            estrogens[index].setSiteBackup(to: name)
        }
    }
    
    /// Returns the index of the given estrogen.
    public func getIndex(for estrogen: MOEstrogen) -> Index? {
        return estrogens.index(of: estrogen)
    }
    
    /// Returns the next MOEstrogen that needs to be taken.
    public func nextDue() -> MOEstrogen? {
        estrogens.sort(by: <)
        if count() > 0 {
            return estrogens[0]
        }
        return nil
    }
    
    /// Returns the total non-nil dates in given estrogens.
    public func datePlacedCount() -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = (estro.date != nil) ? 1 : 0
            return c + count
        })
    }
    
    /// Returns if there are no dates in the estrogen schedule.
    public func hasNoDates() -> Bool {
        return (estrogens.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    /// Returns if there are no sites in the estrogen schedule.
    public func hasNoSites() -> Bool {
        return (estrogens.filter() {
            $0.getSite() != nil
        }).count == 0
    }
    
    /// Returns if there are no dates or sites in the estrogen schedule.
    public func isEmpty() -> Bool {
        return hasNoDates() && hasNoSites()
    }
    
    /// Returns if each MOEstrogen fromThisIndexOnward is empty.
    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        let c = count()
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if i >= 0 && i < c {
                    let estro = estrogens[i]
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// Returns how many expired estrogens there are in the given estrogens.
    public func totalDue(_ interval: String) -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = (estro.isExpired(interval)) ? 1 : 0
            return c + count
        })
    }
    
    /// Sets all MOEstrogen data between given indices to nil.
    public func reset(start: Index, end: Index) {
        let context = PatchData.getContext()
        for i in start...end {
            if i < count() {
                estrogens[i].reset()
                context.delete(estrogens[i])
            }
        }
        estrogens = Array(estrogens.prefix(start))
        PatchData.save()
    }
    
    // MARK: - Private
    
    /// Initializes generic MOEstrogens.
    private static func new(count: Int) -> [MOEstrogen] {
        let entity = PDStrings.CoreDataKeys.estrogenEntityName
        var estros: [MOEstrogen] = []
        for _ in 0..<count {
            if let estro = PatchData.insert(entity) as? MOEstrogen {
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
        EstrogenSchedule.loadMap(estroMap: &estrogenMap, estroArray: estrogens)
        
    }
    
    public func printEstrogens() {
        print("\n")
        for estro in estrogens {
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
