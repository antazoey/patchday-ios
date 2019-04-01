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

public class EstrogenSchedule: NSObject, PDScheduling {
    
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
    
    override init() {
        super.init()
        let mos_opt: [NSManagedObject]? = PatchData.loadMOs(for: .estrogen)
        if let mos = mos_opt {
            estrogens = mos as! [MOEstrogen]
        }
        if count() <= 0 {
            new()
        }
        sort()
        loadMap()
    }

    // MARK: - Base class overrides
    
    public func count() -> Int {
        return min(estrogens.count, quantity)
    }

    /// Creates a new MOEstrogen and appends it to the estrogens.
    public func insert(completion: (() -> ())? = nil) -> NSManagedObject? {
        let type = PDEntity.estrogen.rawValue
        if let estro: MOEstrogen = PatchData.insert(type) as! MOEstrogen? {
            quantity += 1
            estrogens.append(estro)
            let id = estro.setId()
            estrogenMap[id] = estro
            sort()
            return estro
        }
        return nil
    }
    
    public func sort() {
        estrogens.sort(by: <)
    }
    
    /// Reset the schedule to factory default
    public func reset(completion: (() -> ())?) {
        let context = PatchData.getContext()
        for estro in estrogens {
            estro.reset()
            context.delete(estro)
        }
        quantity = (usingPatches) ? 3 : 1
        new()
        loadMap()
        PatchData.save()
        if let comp = completion {
            comp()
        }
    }
    
    /// Resets without changing the quantity
    public func new() {
        estrogens.removeAll()
        reset(from: 0)
        quantity = usingPatches ? 3 : 1
        for _ in 0..<quantity {
            let type = PDEntity.estrogen.rawValue
            let mo = type
            if let estro = PatchData.insert(mo) as? MOEstrogen {
                estrogens.append(estro)
            } else {
                PatchDataAlert.alertForCoreDataError()
            }
        }
    }
    
    // MARK: - Public

    func delete(after i: Index) {
        let start = (i >= -1) ? i + 1 : 0
        let end = count()
        if end >= start {
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
    public func getEstrogen(at index: Index) -> MOEstrogen? {
        switch index {
            case 0..<count() :
                return estrogens[index]
        default : return nil
        }
    }

    /// Returns the MOEstrogen for the given id.
    public func getEstrogen(for id: UUID) -> MOEstrogen? {
        return estrogenMap[id]
    }
    
    /// Sets the site of the MOEstrogen for the given index.
    public func setSite(of index: Index, with site: MOSite,
                        setSharedData: (() -> ())?) {
        let estro = getEstrogen(at: index)
        estro?.setSite(site)
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date of the MOEstrogen for the given index.
    public func setDate(of index: Index, with date: Date,
                        setSharedData: (() -> ())?) {
        let estro = getEstrogen(at: index)
        estro?.setDate(date as NSDate)
        sort()
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given id.
    public func setEstrogen(for id: UUID,
                            date: NSDate,
                            site: MOSite,
                            setSharedData: (() -> ())?) {
        if let estro = getEstrogen(for: id) {
            estro.setSite(site)
            estro.setDate(date)
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
            PatchData.save()
        }
    }
    
    /// Returns the index of the given estrogen.
    public func getIndex(for estrogen: MOEstrogen) -> Index? {
        return estrogens.firstIndex(of: estrogen)
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
        return (estrogens.count == 0) || (estrogens.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    /// Returns if there are no sites in the estrogen schedule.
    public func hasNoSites() -> Bool {
        return (estrogens.count == 0) || (estrogens.filter() {
            $0.getSite() != nil || $0.getSiteNameBackUp() != nil
        }).count == 0
    }
    
    /// Returns if there are no dates or sites in the estrogen schedule.
    public func isEmpty() -> Bool {
        return estrogens.count == 0 || (hasNoDates() && hasNoSites())
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
        if quantity != estrogens.count {
            quantity = estrogens.count
        }
        switch(start) {
        case 0..<quantity :
            let context = PatchData.getContext()
            for i in start..<quantity {
                estrogens[i].reset()
                context.delete(estrogens[i])
            }
            estrogens = Array(estrogens.prefix(start))
            loadMap()
            quantity = start
            PatchData.save()
        default : return
        }
    }

    /// Load estrogen Id map after changes occur to the schedule.
    private func loadMap() {
        estrogenMap.removeAll()
        estrogenMap = estrogens.reduce([UUID: MOEstrogen]()) {
            (estroDict, estro) -> [UUID: MOEstrogen] in
            var dict = estroDict
            if let id = estro.getId() {
                dict[id] = estro
            } else {
                let id = estro.setId()
                dict[id] = estro
            }
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
            } else if let n = estro.getSiteNameBackUp() {
                print(n)
            }
            print("---")
        }
    }
}
