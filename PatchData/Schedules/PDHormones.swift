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


public class PDHormones: NSObject, HormoneScheduling {

    override public var description: String { return "Schedule for hormones." }
    
    private var hormones: [Hormonal]
    
    init(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD) {
        hormones = PatchData.createHormones(
            expirationInterval: interval,
            deliveryMethod: deliveryMethod
        )
        super.init()
        if hormones.count <= 0{
            reset(deliveryMethod: deliveryMethod, interval: interval)
        }
        sort()
    }

    public var count: Int { return hormones.count }
    
    public var all: [Hormonal] { return hormones }
    
    public var isEmpty: Bool {
        return hormones.count == 0 || (hasNoDates && hasNoSites)
    }
    
    public var next: Hormonal? {
        sort()
        return count > 0 ? hormones[0] : nil
    }

    @discardableResult public func insertNew(
        deliveryMethod: DeliveryMethod, expiration: ExpirationIntervalUD
    ) -> Hormonal? {
        if let mone = PDHormone.new(expiration: expiration, deliveryMethod: deliveryMethod) {
            hormones.append(mone)
            sort()
            return mone
        }
        return nil
    }
    
    public func forEach(doThis: (Hormonal) -> ()) {
        hormones.forEach(doThis)
    }
    
    public func sort() {
        if var mones = hormones as? [PDHormone] {
            mones.sort(by: <)
        }
    }

    @discardableResult public func reset(
        deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD
    ) -> Int {
        return reset(deliveryMethod: deliveryMethod, interval: interval, completion: nil)
    }

    @discardableResult public func reset(
        deliveryMethod: DeliveryMethod,
        interval: ExpirationIntervalUD,
        completion: (() -> ())?
    ) -> Int {
        deleteAll()
        let quantity = PDKeyStorableHelper.defaultQuantity(for: deliveryMethod)
        for _ in 0..<quantity {
            insertNew(deliveryMethod: deliveryMethod, expiration: interval)
        }
        if let comp = completion {
            comp()
        }
        PatchData.save()
        return hormones.count
    }

    public func delete(after i: Index) {
        let start = i >= -1 ? i + 1 : 0
        if count >= start {
            for _ in start..<count {
                if let mone = hormones.popLast() {
                    mone.delete()
                }
            }
            PatchData.save()
        }
    }
    
    public func deleteAll() {
        delete(after: -1)
    }

    public func at(_ index: Index) -> Hormonal? {
        switch index {
            case 0..<count :
                return hormones[index]
        default : return nil
        }
    }

    public func get(for id: UUID) -> Hormonal? {
        return hormones.filter({(mone: Hormonal) -> Bool in return mone.id == id })[0]
    }

    public func set(for id: UUID, date: Date, site: Bodily) {
        if var mone = get(for: id) {
            mone.site = site
            mone.date = date
            sort()
        }
    }

    public func set(at index: Index, date: Date, site: Bodily) {
        if var mone = at(index) {
            mone.site = site
            mone.date = date
            sort()
        }
    }

    public func setSite(at index: Index, with site: Bodily) {
        if var mone = at(index) { mone.site = site }
    }

    public func setDate(at index: Index, with date: Date) {
        if var mone = at(index) { mone.date = date }
        sort()
    }

    public func setBackUpSiteName(at index: Index, with name: String) {
        if var mone = at(index) {
            mone.siteNameBackUp = name
            PatchData.save()
        }
    }

    public func indexOf(_ hormone: Hormonal) -> Index? {
        var i = -1
        for mone in hormones {
            i += 1
            if mone.id == hormone.id {
                return i
            }
        }
        return nil
    }

    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if let mone = at(i), mone.isEmpty {
                    return false
                }
            }
        }
        return true
    }

    public func totalExpired(_ interval: ExpirationIntervalUD) -> Int {
        return hormones.reduce(0, {
            count, mone in
            let c = mone.isExpired ? 1 : 0
            return c + count
        })
    }

    public func fillIn(
        newQuantity: Int,
        expiration: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethod
    ) {
        for _ in count..<newQuantity {
            insertNew(deliveryMethod: deliveryMethod, expiration: expiration)
        }
    }
    
    // MARK: - Private
    
    private var hasNoDates: Bool {
        return isEmpty || (hormones.filter() {
            !$0.date.isDefault()
        }).count == 0
    }
    
    private var hasNoSites: Bool {
        return isEmpty || (hormones.filter() {
            $0.site != nil || $0.siteNameBackUp != nil
        }).count == 0
    }
}
