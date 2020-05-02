//
//  HormoneSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class HormoneIterator: IteratorProtocol {
    private var cursor: Index = 0
    var hormones: [Hormonal]

    public init(_ hormones: [Hormonal]) {
        self.hormones = hormones
    }

    public func next() -> Hormonal? {
        let hormone = hormones.tryGet(at: cursor)
        cursor += 1
        return hormone
    }
}

public class HormoneSchedule: NSObject, HormoneScheduling {

	override public var description: String { "Schedule for hormones." }

	private var store: HormoneStoring
	private let dataSharer: HormoneDataSharing
	private let settings: UserDefaultsWriting
	private var hormones: [Hormonal]

	private lazy var log = PDLog<HormoneSchedule>()

	init(store: HormoneStoring, hormoneDataSharer: HormoneDataSharing, settings: UserDefaultsWriting) {
		let store = store
		self.store = store
		self.dataSharer = hormoneDataSharer
		self.settings = settings
		self.hormones = HormoneSchedule.getHormoneList(from: store, settings: settings)
		super.init()
		resetIfEmpty()
		sort()
		shareData()
	}

    public func makeIterator() -> HormoneIterator {
        HormoneIterator(hormones)
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
		let props = HormoneScheduleProperties(settings)
		guard let hormone = store.createNewHormone(props) else { return nil }
		hormones.append(hormone)
		sort()
		return hormone
	}

	public func forEach(doThis: (Hormonal) -> Void) {
		hormones.forEach(doThis)
	}

	public func sort() {
		hormones.sort { $0.date < $1.date && !$0.date.isDefault() || $1.date.isDefault() }
	}

	@discardableResult
	public func resetIfEmpty() -> Int {
		guard count == 0 else { return count }
		log.info("No stored hormones - resetting to default")
		return reset()
	}

	@discardableResult
	public func reset() -> Int {
		reset(completion: nil)
	}

	@discardableResult
	public func reset(completion: (() -> Void)?) -> Int {
		deleteAll()
		let method = settings.deliveryMethod.value
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

	public subscript(index: Index) -> Hormonal? {
		hormones.tryGet(at: index)
	}

	public subscript(id: UUID) -> Hormonal? {
		hormones.first(where: { h in h.id == id })
	}

	public func set(by id: UUID, date: Date, site: Bodily, incrementSiteIndex: Bool) {
		guard var hormone = self[id] else { return }
		set(&hormone, date: date, site: site, incrementSiteIndex: incrementSiteIndex)
	}

	public func set(at index: Index, date: Date, site: Bodily, incrementSiteIndex: Bool) {
		guard var hormone = self[index] else { return }
		set(&hormone, date: date, site: site, incrementSiteIndex: incrementSiteIndex)
	}

	public func setSite(at index: Index, with site: Bodily, incrementSiteIndex: Bool) {
		guard var hormone = self[index] else { return }
		setSite(&hormone, with: site)
		if incrementSiteIndex {
			settings.incrementStoredSiteIndex()
		}
	}

	public func setSite(by id: UUID, with site: Bodily, incrementSiteIndex: Bool) {
		guard var hormone = self[id] else { return }
		setSite(&hormone, with: site)
		if incrementSiteIndex {
			settings.incrementStoredSiteIndex()
		}
	}

	public func setDate(at index: Index, with date: Date) {
		guard var hormone = self[index] else { return }
		setDate(&hormone, with: date)
	}

	public func setDate(by id: UUID, with date: Date) {
		guard var hormone = self[id] else { return }
		setDate(&hormone, with: date)
	}

	public func indexOf(_ hormone: Hormonal) -> Index? {
		hormones.firstIndex { (_ h: Hormonal) -> Bool in h.id == hormone.id }
	}

	public func fillIn(to stopCount: Int) {
		guard count < stopCount else { return }
		for _ in count..<stopCount {
			insertNew()
		}
	}

	public func shareData() {
		guard let nextHormone = next else { return }
		dataSharer.share(nextHormone: nextHormone)
	}

	// MARK: - Private

	private var hasDates: Bool {
		hormones.filter { !$0.date.isDefault() }.count > 0
	}

	private var hasSites: Bool {
		hormones.filter { $0.siteId != nil || ($0.siteNameBackUp != nil && $0.siteNameBackUp != "") }.count > 0
	}

	private func set(_ hormone: inout Hormonal, date: Date, site: Bodily, incrementSiteIndex: Bool) {
		hormone.siteId = site.id
		hormone.date = date
		sort()
		pushFromDateAndSiteChange(hormone, doSave: true)
		if incrementSiteIndex {
			settings.incrementStoredSiteIndex()
		}
	}

	private func setSite(_ hormone: inout Hormonal, with site: Bodily) {
		hormone.siteId = site.id
		hormone.siteName = site.name
		shareData()
		store.pushLocalChangesToManagedContext([hormone], doSave: true)
	}

	private func setDate(_ hormone: inout Hormonal, with date: Date) {
		hormone.date = date
		sort()
		shareData()
		store.pushLocalChangesToManagedContext([hormone], doSave: true)
	}

	private static func getHormoneList(from store: HormoneStoring, settings: UserDefaultsReading) -> [Hormonal] {
		store.getStoredHormones(HormoneScheduleProperties(settings))
	}

	private func pushFromDateAndSiteChange(_ hormone: Hormonal, doSave: Bool) {
		store.pushLocalChangesToManagedContext([hormone], doSave: doSave)
		shareData()
	}
}
