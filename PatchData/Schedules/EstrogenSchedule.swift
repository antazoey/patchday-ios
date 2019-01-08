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
        return """
               Schedule for reading, writing,
               and querying the MOEstrogen array.
               """
    }
    
    public var estrogens: [MOEstrogen] = []
    internal var quantity = 3
    internal var usingPatches = true
    private var estrogenMap = [UUID: MOEstrogen]()
    
    init() {
        super.init(type: .estrogen)
        // Create a new schedule if no stored estrogens
        estrogens = mos as! [MOEstrogen]
        mos = []
        if count() <= 0 {
            new()
        }
        loadMap()
    }

    // MARK: - Base class overrides
    
    override public func count() -> Int {
        return min(estrogens.count, quantity)
    }

    /// Creates a new MOEstrogen and appends it to the estrogens.
    override public func insert(completion: (() -> ())? = nil) -> MOEstrogen? {
        if let estro = PatchData.insert(type.rawValue) as! MOEstrogen? {
            quantity += 1
            estrogens.append(estro)
            estrogenMap[estro.getID()] = estro
            sort()
            estro.setID()
            return estro
        }
        return nil
    }
    
    override public func sort() {
        estrogens.sort(by: <)
    }
    
    /// Reset the schedule to factory default
    override public func reset(completion: (() -> ())?) {
        let context = PatchData.getContext()
        for estro in estrogens {
            estro.reset()
            context.delete(estro)
        }
        quantity = (usingPatches) ? 3 : 1
        new()
        PatchData.save()
        if let comp = completion {
            comp()
        }
    }
    
    /// Resets without changing the quantity
    override public func new() {
        estrogens = []
        for _ in 0..<quantity {
            let mo = type.rawValue
            if let estro = PatchData.insert(mo) as? MOEstrogen {
                estro.setID()
                estrogens.append(estro)
            } else {
                PatchDataAlert.alertForCoreDataError()
            }
        }
    }
    
    // MARK: - Public

    public func delete(after i: Index) {
        let end = count()
        let start = (i >= -1) ? i + 1 : 0
        if end > start {
            for _ in start..<end {
                if let estro = estrogens.popLast() {
                    quantity -= 1
                    PatchData.getContext().delete(estro)
                }
            }
            PatchData.save()
        }
    }
    
    /// Returns the MOEstrogen for the given index
    // or creates one where one should be.
    public func getEstrogen(at index: Index, insertOnFail: Bool = true) -> MOEstrogen? {
        if index >= 0, index < count() {
            return estrogens[index]
        } else if insertOnFail {
            return insert(completion: nil)
        }
        return nil
    }

    /// Returns the MOEstrogen for the given id.
    public func getEstrogen(for id: UUID) -> MOEstrogen? {
        return estrogenMap[id]
    }
    
    /// Sets the site of the MOEstrogen for the given index.
    public func setSite(of index: Index, with site: MOSite,
                        setSharedData: (() -> ())?) {
        let estro = getEstrogen(at: index)
        estro?.setSite(with: site)
        // TODO
        //PDSharedData.setEstrogenDataForToday()
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date of the MOEstrogen for the given index.
    public func setDate(of index: Index, with date: Date,
                        setSharedData: (() -> ())?) {
        let estro = getEstrogen(at: index)
        estro?.setDate(with: date as NSDate)
        sort()
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, date: NSDate, site: MOSite,
                            setSharedData: (() -> ())?) {
        let estro = getEstrogen(at: index)
        estro?.setSite(with: site)
        estro?.setDate(with: date)
        sort()
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given id.
    public func setEstrogen(for id: UUID, date: NSDate, site: MOSite,
                            setSharedData: (() -> ())?) {
        if let estro = getEstrogen(for: id) {
            estro.setSite(with: site)
            estro.setDate(with: date)
            sort()
            if let todaySet = setSharedData {
                todaySet()
            }
            PatchData.save()
        }
    }
    
    /// Sets the MOEstrogen for the given index.
    public func setEstrogen(of index: Index, with estrogen: MOEstrogen,
                            setSharedData: (() -> ())?) {
        if index < count() && index >= 0 {
            estrogens[index] = estrogen
            sort()
            if let todaySet = setSharedData {
                todaySet()
            }
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
        sort()
        if count() > 0 {
            return estrogens[0]
        }
        return nil
    }
    
    /// Returns the total non-nil dates in given estrogens.
    public func datePlacedCount() -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = (estro.getDate() != nil) ? 1 : 0
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
    public func isEmpty(fromThisIndexOnward: Index,
                        lastIndex: Index) -> Bool {
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
    public func reset(from start: Index) {
        switch(start) {
        case 0..<min(quantity, estrogens.count) :
            let context = PatchData.getContext()
            for i in start..<quantity {
                estrogens[i].reset()
                context.delete(estrogens[i])
            }
            estrogens = Array(estrogens.prefix(start))
            quantity = start
            PatchData.save()
        default : return
        }
    }

    /// Load estrogen ID map after changes occur to the schedule.
    public func loadMap() {
        estrogenMap = estrogens.reduce([UUID: MOEstrogen]()) {
            (estroDict, estro) -> [UUID: MOEstrogen] in
            var dict = estroDict
            dict[estro.getID()] = estro
            return dict
        }
    }

    public func printEstrogens() {
        print("\n")
        for estro in estrogens {
            print("Estrogen")
            if let d = estro.getDate() {
                print(PDDateHelper.format(date: d as Date,
                                          useWords: true))
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
