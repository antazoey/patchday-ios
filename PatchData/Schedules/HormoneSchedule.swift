//
//  HormoneSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class HormoneSchedule: NSObject, HormoneScheduling {
    
    override public var description: String { "Schedule for hormones." }

    private var store: HormoneStoring
    private let dataSharer: HormoneDataSharing
    private var state: PDState
    private let defaults: UserDefaultsWriting
    private var hormones: [Hormonal]

    private let log = PDLog<HormoneSchedule>()
    
    init(
        store: HormoneStoring,
        hormoneDataSharer: HormoneDataSharing,
        state: PDState,
        defaults: UserDefaultsWriting
    ) {
        let store = store
        self.store = store
        self.dataSharer = hormoneDataSharer
        self.state = state
        self.defaults = defaults
        self.hormones = HormoneSchedule.getHormoneList(from: store, defaults: defaults)
        super.init()
        resetIfEmpty()
        sort()
        shareData()
    }

    public var count: Int { hormones.count }
    
    public var all: [Hormonal] { hormones }
    
    public var isEmpty: Bool {
        let hasNoDates = !hasDates
        let hasNoSites = !hasSites
        return hormones.count == 0 || (hasNoDates && hasNoSites)
    }
    
    public var next: Hormonal? {
        sort()
        return hormones.tryGet(at: 0)
    }
    
    public var totalExpired: Int {
        hormones.reduce(0, {
            count, hormone in
            let c = hormone.isExpired ? 1 : 0
            return c + count
        })
    }

    @discardableResult
    public func insertNew() -> Hormonal? {
        if let hormone = store.createNewHormone(HormoneScheduleProperties(defaults)) {
            hormones.append(hormone)
            sort()
            return hormone
        }
        return nil
    }
    
    public func forEach(doThis: (Hormonal) -> ()) {
        hormones.forEach(doThis)
    }
    
    public func sort() {
        hormones.sort(by: HormoneComparator.lessThan)
    }

    @discardableResult
    public func resetIfEmpty() -> Int {
        if count == 0 {
            log.info("No stored hormones - resetting to default")
            return reset()
        }
        return count
    }
    
    @discardableResult
    public func reset() -> Int {
        reset(completion: nil)
    }

    @discardableResult
    public func reset(completion: (() -> ())?) -> Int {
        deleteAll()
        let method = defaults.deliveryMethod.value
        let quantity = KeyStorableHelper.defaultQuantity(for: method)
        for _ in 0..<quantity {
            insertNew()
        }
        completion?()
        saveAll()
        return hormones.count
    }

    public func delete(after i: Index) {
        let start = i >= -1 ? i + 1 : 0
        guard count >= start else {
            log.error("Attempted to delete hormones after index \(i) when the count is only \(count)")
            return
        }
        for _ in start..<count {
            if let hormone = hormones.popLast() {
                store.delete(hormone)
            }
        }
    }

    public func saveAll() {
        guard count > 0 else { return }
        store.pushLocalChangesToManagedContext(hormones, doSave: true)
    }
    
    public func deleteAll() {
        guard count > 0 else { return }
        delete(after: -1)
    }

    public func at(_ index: Index) -> Hormonal? {
        hormones.tryGet(at: index)
    }

    public func get(by id: UUID) -> Hormonal? {
        hormones.first(where: { h in h.id == id })
    }

    public func set(by id: UUID, date: Date, site: Bodily, doSave: Bool) {
        if var hormone = get(by: id) {
            set(&hormone, date: date, site: site, doSave: doSave)
        }
    }

    public func set(at index: Index, date: Date, site: Bodily, doSave: Bool) {
        if var hormone = at(index) {
            set(&hormone, date: date, site: site, doSave: doSave)
        }
    }

    public func setSite(at index: Index, with site: Bodily, doSave: Bool) {
        if var hormone = at(index) {
            setSite(&hormone, with: site, doSave: doSave)
        }
    }

    public func setSite(by id: UUID, with site: Bodily, doSave: Bool) {
        if var hormone = get(by: id) {
            setSite(&hormone, with: site, doSave: doSave)
        }
    }

    public func setDate(at index: Index, with date: Date, doSave: Bool) {
        if var hormone = at(index) {
            setDate(&hormone, with: date, doSave: doSave)
        }
    }

    public func setDate(by id: UUID, with date: Date, doSave: Bool) {
        if var hormone = get(by: id) {
            setDate(&hormone, with: date, doSave: doSave)
        }
    }

    public func firstIndexOf(_ hormone: Hormonal) -> Index? {
        hormones.firstIndex { (_ h: Hormonal) -> Bool in h.id == hormone.id }
    }
    
    public func fillIn(to stopCount: Int) {
        for _ in count..<stopCount {
            insertNew()
        }
    }
    
    public func shareData() {
        if let nextHormone = next {
            dataSharer.share(nextHormone: nextHormone)
        }
    }
    
    public static func getOldestHormoneDate(from hormones: [HormoneStruct]) -> Date {
        return hormones.reduce(Date(), { (oldestDateThusFar, hormone) in
            if let date = hormone.date, date < oldestDateThusFar {
                return date
            }
            return oldestDateThusFar
        })
    }
    
    // MARK: - Private
    
    private var hasDates: Bool {
        let dateCount = hormones.filter { !$0.date.isDefault() }.count
        return dateCount > 0
    }
    
    private var hasSites: Bool {
        let siteCount = hormones.filter {
            $0.siteId != nil || ($0.siteNameBackUp != nil && $0.siteNameBackUp != "")
        }.count
        return siteCount > 0
    }
    
    private func set(_ hormone: inout Hormonal, date: Date, site: Bodily, doSave: Bool) {
        hormone.siteId = site.id
        hormone.date = date
        sort()
        pushFromDateAndSiteChange(hormone, doSave: doSave)
    }
    
    private func setSite(_ hormone: inout Hormonal, with site: Bodily, doSave: Bool) {
        hormone.siteId = site.id
        hormone.siteName = site.name
        state.bodilyChanged = true
        state.onlySiteChanged = true
        state.bodilyChanged = true
        shareData()
        store.pushLocalChangesToManagedContext([hormone], doSave: doSave)
    }
    
    private func setDate(_ hormone: inout Hormonal, with date: Date, doSave: Bool) {
        hormone.date = date
        sort()
        shareData()
        state.onlySiteChanged = false
        store.pushLocalChangesToManagedContext([hormone], doSave: doSave)
    }

    private static func getHormoneList(from store: HormoneStoring, defaults: UserDefaultsReading) -> [Hormonal] {
        let props = HormoneScheduleProperties(defaults)
        return store.getStoredHormones(props)
    }

    private func pushFromDateAndSiteChange(_ hormone: Hormonal, doSave: Bool) {
        store.pushLocalChangesToManagedContext([hormone], doSave: doSave)
        shareData()
        state.onlySiteChanged = false
        state.bodilyChanged = true
    }
}
