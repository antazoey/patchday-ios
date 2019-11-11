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


public struct HormoneScheduleData {
    var deliveryMethod: DeliveryMethodUD
    var expirationInterval: ExpirationIntervalUD
}


public class PDHormones: NSObject, HormoneScheduling {
    
    override public var description: String { "Schedule for hormones." }

    private let dataBroadcaster: HormoneDataBroadcasting
    private var store: PatchDataCalling
    private var state: PDStateManaging
    private let defaults: PDDefaultStoring
    private var hormones: [Hormonal]
    
    init(
        data: HormoneScheduleData,
        hormoneDataBroadcaster: HormoneDataBroadcasting,
        store: PatchDataCalling,
        stateManager: PDStateManaging,
        defaults: PDDefaultStoring
    ) {
        self.hormones = PDHormones.createHormones(data: data)
        self.dataBroadcaster = hormoneDataBroadcaster
        self.store = store
        self.state = stateManager
        self.defaults = defaults
        super.init()
        reset()
        sort()
        broadcastHormones()
    }

    public var count: Int { hormones.count }
    
    public var all: [Hormonal] { hormones }
    
    public var isEmpty: Bool { hormones.count == 0 || (hasNoDates && hasNoSites) }
    
    public var next: Hormonal? {
        sort()
        return count > 0 ? hormones[0] : nil
    }
    
    public var totalExpired: Int {
        hormones.reduce(0, {
            count, mone in
            let c = mone.isExpired ? 1 : 0
            return c + count
        })
    }

    @discardableResult public func insertNew() -> Hormonal? {
        let method = defaults.deliveryMethod.value
        let exp = defaults.expirationInterval
        if let mone = PDHormone.new(expiration: exp, deliveryMethod: method) {
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

    @discardableResult public func reset() -> Int {
        reset(completion: nil)
    }

    @discardableResult public func reset(completion: (() -> ())?) -> Int {
        deleteAll()
        let method = defaults.deliveryMethod.value
        let quantity = PDKeyStorableHelper.defaultQuantity(for: method)
        for _ in 0..<quantity {
            insertNew()
        }
        if let comp = completion {
            comp()
        }
        store.save()
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
            store.save()
        }
    }
    
    public func deleteAll() {
        delete(after: -1)
    }

    public func at(_ index: Index) -> Hormonal? {
        hormones.tryGet(at: index)
    }

    public func get(for id: UUID) -> Hormonal? {
        return hormones.filter(
            {(mone: Hormonal) -> Bool in
                return mone.id == id
            }).tryGet(at: 0)
    }

    public func set(for id: UUID, date: Date, site: Bodily) {
        if var mone = get(for: id) {
            mone.site = site
            mone.date = date
            sort()
            saveFromDateAndSiteChange()
        }
    }

    public func set(at index: Index, date: Date, site: Bodily) {
        if var mone = at(index) {
            mone.site = site
            mone.date = date
            sort()
            saveFromDateAndSiteChange()
        }
    }

    public func setSite(at index: Index, with site: Bodily) {
        if var mone = at(index) {
            mone.site = site
            store.save()
            state.bodilyChanged = true
            state.onlySiteChanged = true
            state.bodilyChanged = true
            broadcastHormones()
        }
    }

    public func setDate(at index: Index, with date: Date) {
        if var mone = at(index) {
            mone.date = date
            sort()
            store.save()
            broadcastHormones()
            state.onlySiteChanged = false
        }
    }

    public func setBackUpSiteName(at index: Index, with name: String) {
        if var mone = at(index) {
            mone.siteNameBackUp = name
            store.save()
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

    public func fillIn(newQuantity: Int) {
        for _ in count..<newQuantity {
            insertNew()
        }
    }
    
    // MARK: - Private
    
    private var hasNoDates: Bool {
        isEmpty || (hormones.filter() {
            !$0.date.isDefault()
        }).count == 0
    }
    
    private var hasNoSites: Bool {
        isEmpty || (hormones.filter() {
            $0.site != nil || $0.siteNameBackUp != nil
        }).count == 0
    }
    
    private static func createHormones(data: HormoneScheduleData) -> [Hormonal] {
        PatchData.createHormones(
            expirationInterval: data.expirationInterval,
            deliveryMethod: data.deliveryMethod.value
        )
    }
    
    private func broadcastHormones() {
        dataBroadcaster.broadcast(nextHormone: next)
    }
    
    private func saveFromDateAndSiteChange() {
        store.save()
        broadcastHormones()
        state.onlySiteChanged = false
        state.bodilyChanged = true
    }
}
