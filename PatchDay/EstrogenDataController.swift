//
//  EstrogenDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class EstrogenDataController {
    
    internal var estrogenArray: [MOEstrogen]
    internal let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        estrogenArray = []
        // Load previously saved MOEstrogens
        if let estros = EstrogenDataController.loadEstrogenMOs(from: context) {
            estrogenArray = estros
        }
            // New MOEstrogens if all else fails
        else {
            estrogenArray = EstrogenDataController.newEstrogenMOs(from: context)
        }
        estrogenArray.sort(by: <)
    }
    
    // MARK: - Public
    
    // Returns the MOEstrogen for the given index or creates one where one should be.
    internal func getEstrogenMO(at index: Index) -> MOEstrogen? {
        if index < 0 || index > 4 {
            return nil
        }
        else if index < UserDefaultsController.getQuantityInt() {
            if index < estrogenArray.count && index >= 0 {
                return estrogenArray[index]
            }
            else {
                let newEstro = createNewEstrogenMO(in: context)
                return newEstro
            }
        }
        else {
            return nil
        }
    }
    
    internal func getEstrogenMO(for id: UUID) -> MOEstrogen? {
        if let estroIndex = estrogenArray.map({
            (estro: MOEstrogen) -> UUID? in
            return estro.getID()
        }).index(of: id) {
            return estrogenArray[estroIndex]
        }
        return nil
    }
    
    internal func setEstrogenSite(of index: Index, with site: MOSite) {
        
        if let estro = getEstrogenMO(at: index) {
            estro.setSite(with: site)
            EstrogenDataController.saveContext(context)
        }
    }
    
    internal func setEstrogenDate(of index: Index, with date: Date) {
        if let estro = getEstrogenMO(at: index) {
            estro.setDate(with: date as NSDate)
            estrogenArray.sort(by: <)
            EstrogenDataController.saveContext(context)
        }
    }
    
    internal func setEstrogenMO(of index: Index, date: NSDate, site: MOSite) {
        if let estro = getEstrogenMO(at: index) {
            estro.setSite(with: site)
            estro.setDate(with: date)
            estrogenArray.sort(by: <)
            EstrogenDataController.saveContext(context)
        }
    }
    
    internal func setEstrogenMO(for id: UUID, date: NSDate, site: MOSite) {
        if let estro = getEstrogenMO(for: id) {
            estro.setSite(with: site)
            estro.setDate(with: date)
            estrogenArray.sort(by: <)
            EstrogenDataController.saveContext(context)
        }
    }
    
    internal func setEstrogenMO(of index: Index, with estrogen: MOEstrogen) {
        if index < estrogenArray.count && index >= 0 {
            estrogenArray[index] = estrogen
            estrogenArray.sort(by: <)
            EstrogenDataController.saveContext(context)
        }
    }
    
    internal func getLowestUndatedIndex() -> Index? {
        let dpc = datePlacedCount()
        
        if dpc != estrogenArray.count {
            return dpc-1
        }
        // All estrogens are dated.
        return nil
    }
    
    // Returns the number of non-nil dates in given estrogens.
    internal func datePlacedCount() -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.date != nil) ? 1 : 0
            return c + count
        })
    }
    
    internal func resetEstrogenData(start_i: Index, end_i: Index) {
        for i in start_i...end_i {
            if let estro = getEstrogenMO(at: i) {
                estro.reset()
            }
        }
        EstrogenDataController.saveContext(context)
    }
    
    public func hasNoDates() -> Bool {
        return (estrogenArray.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    public func hasNoLocations() -> Bool {
        return (estrogenArray.filter() {
            $0.getSite() != nil
        }).count == 0
    }
    
    public func isEmpty() -> Bool {
        return hasNoDates() && hasNoLocations()
    }
    
    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        // returns true if each MOEstrogen fromThisIndexOnward is empty
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
    
    // Returns how many expired estrogens there are in the given estrogens.
    public func expiredCount(_ intervalStr: String) -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.isExpired(intervalStr)) ? 1 : 0
            return c + count
        })
    }
    
    // MARK: - Private
    
    // Brings persisted MOEstrogenDeliveries into memory when starting the app.
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
    
    // Initializes a generic MOEstrogen when there is none in store.
    private static func newEstrogenMOs(from context: NSManagedObjectContext) -> [MOEstrogen] {
        let entityName = PDStrings.CoreDataKeys.estroEntityName
        var estros: [MOEstrogen] = []
        for _ in 0..<PDStrings.PickerData.counts.count {
            if let estro = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? MOEstrogen {
                estros.append(estro)
            }
            else {
                PDAlertController.alertForCoreDataError()
                estros.append(MOEstrogen())
            }
        }
        initIDs(for: estros)
        return estros
    }
    
    // Statically create a new MOEstrogen.
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
    
    // Creates a new MOEstrogen and appends it to the estrogenArray.
    private func createNewEstrogenMO(in context: NSManagedObjectContext) -> MOEstrogen {
        let newEstro = EstrogenDataController.newEstrogenMO(in: context)
        estrogenArray.append(newEstro)
        estrogenArray.sort(by: <)
        EstrogenDataController.initID(for: newEstro)
        return newEstro
    }
    
    // Set UUId for estro if there is none
    private static func initID(for estro: MOEstrogen) {
        if estro.getID() == nil {
            estro.setID(with: UUID())
        }
    }
    
    // Sets UUID for estros if there is none
    private static func initIDs(for estros: [MOEstrogen]) {
        for estro in estros {
            initID(for: estro)
        }
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
