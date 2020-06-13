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
	private let settings: UserDefaultsWriting
	private var context: [Hormonal]

	private lazy var log = PDLog<HormoneSchedule>()

	init(
		store: HormoneStoring,
		hormoneDataSharer: HormoneDataSharing,
		settings: UserDefaultsWriting
	) {
		let store = store
		self.store = store
		self.dataSharer = hormoneDataSharer
		self.settings = settings
		self.context = HormoneSchedule.getHormoneList(from: store, settings: settings)
		super.init()
		resetIfEmpty()
		shareData()
	}

	public var count: Int { all.count }

	public var all: [Hormonal] {
		context.sort { $0.date < $1.date && !$0.date.isDefault() || $1.date.isDefault() }
		return context
	}

	public var isEmpty: Bool {
		let hasNoDates = !hasDates
		let hasNoSites = !hasSites
		return count == 0 || (hasNoDates && hasNoSites)
	}

	public var next: Hormonal? {
		all.tryGet(at: 0)
	}

	public var totalExpired: Int {
		all.reduce(0, {	count, hormone in
			let c = hormone.isExpired ? 1 : 0
			return c + count
		})
	}

	public func reloadContext() {
		self.context = HormoneSchedule.getHormoneList(from: store, settings: settings)
	}

	@discardableResult
	public func insertNew() -> Hormonal? {
		if let hormone = store.createNewHormone(settings) {
			context.append(hormone)
			return hormone
		}
		return nil
	}

	public func forEach(doThis: (Hormonal) -> Void) {
		all.forEach(doThis)
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
		let quantity = DefaultQuantities.Hormone[method]
		for _ in 0..<quantity {
			insertNew()
		}
		completion?()
		saveAll()
		return count
	}

	public func delete(after i: Index) {
		let start = i >= -1 ? i + 1 : 0
		guard count >= start else {
			log.error("Attempted to delete hormones after index " +
				"\(i) when the count is only \(count)")
			return
		}
		for _ in start..<count {
			if let hormone = context.popLast() {
				store.delete(hormone)
			}
		}
	}

	public func saveAll() {
		guard count > 0 else { return }
        store.pushLocalChangesToManagedContext(context, doSave: true)
	}

	public func deleteAll() {
		guard count > 0 else { return }
		delete(after: -1)
	}

	public subscript(index: Index) -> Hormonal? {
		all.tryGet(at: index)?.from(settings)
	}

	public subscript(id: UUID) -> Hormonal? {
		all.first(where: { h in h.id == id })?.from(settings)
	}

	public func set(by id: UUID, date: Date, site: Bodily) {
		guard var hormone = self[id] else { return }
		set(&hormone, date: date, site: site)

	}

	public func set(at index: Index, date: Date, site: Bodily) {
		guard var hormone = self[index] else { return }
		set(&hormone, date: date, site: site)
	}

	public func setSite(at index: Index, with site: Bodily) {
		guard var hormone = self[index] else { return }
		setSite(&hormone, with: site)
		settings.incrementStoredSiteIndex(from: site.order)

	}

	public func setSite(by id: UUID, with site: Bodily) {
		guard var hormone = self[id] else { return }
		setSite(&hormone, with: site)
		settings.incrementStoredSiteIndex(from: site.order)
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
		all.firstIndex { (_ h: Hormonal) -> Bool in h.id == hormone.id }
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
		all.filter { !$0.date.isDefault() }.count > 0
	}

	private var hasSites: Bool {
		all.filter {
			$0.siteId != nil || ($0.siteNameBackUp != nil && $0.siteNameBackUp != "")
		}.count > 0
	}

	private func set(_ hormone: inout Hormonal, date: Date, site: Bodily) {
		hormone.siteId = site.id
		hormone.date = date
		hormone.siteName = site.imageId
		pushFromDateAndSiteChange(hormone)
		settings.incrementStoredSiteIndex(from: site.order)
	}

	private func setSite(_ hormone: inout Hormonal, with site: Bodily) {
		hormone.siteId = site.id
		hormone.siteName = site.imageId
		shareData()
		store.pushLocalChangesToManagedContext([hormone], doSave: true)
		settings.incrementStoredSiteIndex(from: site.order)
	}

	private func setDate(_ hormone: inout Hormonal, with date: Date) {
		hormone.date = date
		shareData()
		store.pushLocalChangesToManagedContext([hormone], doSave: true)
	}

	private static func getHormoneList(from store: HormoneStoring, settings: UserDefaultsReading) -> [Hormonal] {
		store.getStoredHormones(settings)
	}

	private func pushFromDateAndSiteChange(_ hormone: Hormonal) {
		store.pushLocalChangesToManagedContext([hormone], doSave: true)
		shareData()
	}
}
