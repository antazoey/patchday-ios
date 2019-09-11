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

public class EstrogenSchedule: NSObject, EstrogenScheduling {

    override public var description: String {
        return "Schedule for reading, writing, and querying the MOEstrogen array."
    }
    
    init(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD) {
        estrogens = PatchData.createEstrogens(expirationInterval: interval, deliveryMethod: deliveryMethod)
        super.init()
        if estrogens.count <= 0 { new(deliveryMethod: deliveryMethod, interval: interval) }
        sort()
    }
    
    public var estrogens: [Hormonal]
    
    public var isEmpty: Bool {
        return estrogens.count == 0 || (hasNoDates && hasNoSites)
    }
    
    public var next: Hormonal? {
        sort()
        if estrogens.count > 0 { return estrogens[0] }
        return nil
    }

    /// Creates a new MOEstrogen and appends it to the estrogens.
    public func insert(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        if let estro = PDEstrogen.createNew(expiration: expiration, deliveryMethod: deliveryMethod) {
            estrogens.append(estro)
            sort()
            return estro
        }
        return nil
    }
    
    public func sort() {
        if var estros = estrogens as? [PDEstrogen] {
            estros.sort(by: <)
        }
    }
    
    /// Reset the schedule to factory default
    public func reset(completion: (() -> ())?, deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD) {
        for estro in estrogens {
            estro.reset()
            estro.delete()
        }
        new(deliveryMethod: deliveryMethod, interval: interval)
        PatchData.save()
        if let comp = completion {
            comp()
        }
    }
    
    /// Sets all MOEstrogen data between given indices to nil.
    public func reset(from start: Index) {
        switch(start) {
        case 0..<estrogens.count :
            let context = PatchData.getContext()
            for i in start..<estrogens.count {
                estrogens[i].reset()
                context.delete(estrogens[i] as! NSManagedObject)
            }
            estrogens = Array(estrogens.prefix(start))
            PatchData.save()
        default : return
        }
    }
    
    /// Resets without changing the quantity
    public func new(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD) {
        estrogens.removeAll()
        reset(from: 0)
        let quantity = deliveryMethod == .Injections ? 1 : 3
        for _ in 0..<quantity {
            _ = insert(expiration: interval, deliveryMethod: deliveryMethod)
        }
    }

    public func delete(after i: Index) {
        let start = (i >= -1) ? i + 1 : 0
        if estrogens.count >= start {
            for _ in start..<estrogens.count {
                if let estro = estrogens.popLast() {
                    estro.delete()
                }
            }
            PatchData.save()
        }
    }
    
    /// Returns the MOEstrogen for the given index
    public func getEstrogen(at index: Index) -> Hormonal? {
        switch index {
            case 0..<estrogens.count :
                return estrogens[index]
        default : return nil
        }
    }

    /// Returns the MOEstrogen for the given id.
    public func getEstrogen(for id: UUID) -> Hormonal? {
        return estrogens.filter({(estro: Hormonal) -> Bool in return estro.id == id })[0]
    }
    
    /// Sets the site of the MOEstrogen for the given index.
    public func setSite(of index: Index, with site: Bodily, setSharedData: (() -> ())?) {
        if var estro = getEstrogen(at: index) {
            estro.site = site
        }
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date of the MOEstrogen for the given index.
    public func setDate(of index: Index, with date: Date, setSharedData: (() -> ())?) {
        if var estro = getEstrogen(at: index) {
            estro.date = date
        }
        sort()
        if let todaySet = setSharedData {
            todaySet()
        }
        PatchData.save()
    }
    
    /// Sets the date and the site of the MOEstrogen for the given id.
    public func setEstrogen(for id: UUID, date: Date, site: Bodily, setSharedData: (() -> ())?) {
        if var estro = getEstrogen(for: id) {
            estro.site = site
            estro.date = date
            sort()
            if let todaySet = setSharedData {
                todaySet()
            }
            PatchData.save()
        }
    }
    
    /// Sets the backup-site-name of the MOEstrogen for the given index.
    public func setBackUpSiteName(of index: Index, with name: String) {
        if var estro = getEstrogen(at: index) {
            estro.siteNameBackUp = name
            PatchData.save()
        }
    }
    
    /// Returns the index of the given estrogen.
    public func indexOf(_ estrogen: Hormonal) -> Index? {
        var i = -1
        for estro in estrogens {
            i += 1
            if estro.id == estrogen.id {
                return i
            }
        }
        return -1
    }
    
    /// Returns if each MOEstrogen fromThisIndexOnward is empty.
    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if i >= 0 && i < estrogens.count {
                    let estro = estrogens[i]
                    if !estro.isEmpty {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// Returns how many expired estrogens there are in the given estrogens.
    public func totalDue(_ interval: ExpirationIntervalUD) -> Int {
        return estrogens.reduce(0, {
            count, estro in
            let c = estro.isExpired ? 1 : 0
            return c + count
        })
    }
    
    // MARK: - Private
    
    private var hasNoDates: Bool {
        get {
            return (estrogens.count == 0) || (estrogens.filter() {
                !$0.date.isDefault()
            }).count == 0
        }
    }
    
    private var hasNoSites: Bool {
        get {
            return (estrogens.count == 0) || (estrogens.filter() {
                $0.site != nil || $0.siteNameBackUp != nil
            }).count == 0
        }
    }
}
