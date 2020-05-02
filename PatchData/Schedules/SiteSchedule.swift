//
//  SiteSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class SiteSchedule: NSObject, SiteScheduling {

	override public var description: String { "Schedule for sites." }
	private var resetWhenEmpty: Bool

	private let store: SiteStoring
	private let settings: UserDefaultsWriting
	private var sites: [Bodily]

	private lazy var log = PDLog<SiteSchedule>()

	init(store: SiteStoring, settings: UserDefaultsWriting, resetWhenEmpty: Bool = true) {
		self.store = store
		self.settings = settings
		self.resetWhenEmpty = resetWhenEmpty
		self.sites = store.getStoredSites()
		super.init()
		handleSiteCount()
		sort()
		ensureValidOrdering()
	}

	public var count: Int { sites.count }

	public var all: [Bodily] { sites }

	public var suggested: Bodily? {
		guard count > 0 else { return nil }
		if let shouldBeSuggestedSite = firstEmptyFromSiteIndex ?? siteWithOldestHormone {
			// If the current siteIndex is not actually pointing to the correct 'suggested',
			// fix it here before giving the correct suggested site.
			if shouldBeSuggestedSite.id != suggestedSite?.id {
				settings.replaceStoredSiteIndex(to: shouldBeSuggestedSite.order)
			}

			return shouldBeSuggestedSite
		}
		return suggestedSite
	}

	public var nextIndex: Index {
		sites.firstIndex(where: { b in
			if let suggestedSite = suggested {
				return suggestedSite.id == b.id
			}
			return false
		}) ?? -1
	}

	public var names: [SiteName] {
		sites.map({ (site: Bodily) -> SiteName in site.name })
	}

	public var isDefault: Bool {
		guard count > 0 else { return false }
		let method = settings.deliveryMethod.value
		let defaultSites = SiteStrings.getSiteNames(for: method)
		for name in names {
			if !defaultSites.contains(name) {
				return false
			}
		}
		return true
	}

	@discardableResult
	public func insertNew(name: String, save: Bool, onSuccess: (() -> Void)?) -> Bodily? {
		if var site = store.createNewSite(doSave: save) {
			site.name = name
			sites.append(site)
			onSuccess?()
			return site
		}
		return nil
	}

	@discardableResult
	public func reset() -> Int {
		if isDefault {
			log.warn("Resetting sites unnecessary because already default")
			return sites.count
		}
		resetSitesToDefault()
		store.pushLocalChangesToManagedContext(sites, doSave: true)
		return sites.count
	}

	public func delete(at index: Index) {
		if let site = self[index] {
			log.info("Deleting site at index \(index)")
			store.delete(site)
			sites.remove(at: index)

			// index now refers to index - 1
			for i in index...count - 1 {
				if var site = self[i] {
					site.order -= 1
				}
			}
		}
	}

	public func sort() {
		sites.sort {
			// keep negative orders at the end
			if $0.order < 0 {
				return false
			}

			if $1.order < 0 {
				return true
			}
			return $0.order < $1.order
		}
	}

	public subscript(index: Index) -> Bodily? {
		sites.tryGet(at: index)
	}

	public subscript(id: UUID) -> Bodily? {
		sites.first(where: { s in s.id == id })
	}

	public func rename(at index: Index, to name: SiteName) {
		if var site = self[index] {
			site.name = name
			store.pushLocalChangesToManagedContext([site], doSave: true)
		}
	}

	public func reorder(at index: Index, to newOrder: Int) {
		guard sites.count > 0 else { return }
		if var site = self[index], var originalSiteAtOrder = self[newOrder] {
			site.order = site.order + originalSiteAtOrder.order
			originalSiteAtOrder.order = site.order - originalSiteAtOrder.order
			site.order = site.order - originalSiteAtOrder.order
			sort()
			store.pushLocalChangesToManagedContext(sites, doSave: true)
		}
	}

	public func setImageId(at index: Index, to newId: String) {
		guard sites.count > 0 else { return }
		let siteSet = SiteStrings.getSiteNames(for: settings.deliveryMethod.value)
		if var site = self[index] {
			site.imageId = siteSet.contains(newId) ? newId : SiteStrings.CustomSiteId
			store.pushLocalChangesToManagedContext([site], doSave: true)
		}
	}

	public func indexOf(_ site: Bodily) -> Index? {
		sites.firstIndex { (_ s: Bodily) -> Bool in s.id == site.id }
	}

	@discardableResult
	private func updateIndex() -> Index {
		settings.incrementStoredSiteIndex()
	}

	private var suggestedSite: Bodily? {
		if let site = self[settings.siteIndex.value] {
			return site
		}
		return nil
	}

	private var firstEmptyFromSiteIndex: Bodily? {
		var siteIterator = settings.siteIndex.value
		for _ in 0..<count {
			if let site = self[siteIterator], site.hormoneCount == 0 {
				return site
			}
			siteIterator = (siteIterator + 1) % count
		}
		return nil
	}

	private var siteWithOldestHormone: Bodily? {
		sites.reduce((oldestDate: Date(), oldest: nil, iterator: 0), {
				(b, site) in

				if let oldestDateInThisSitesHormones = getOldestHormoneDate(from: site.id),
					oldestDateInThisSitesHormones < b.oldestDate, let site = self[b.iterator] {

					return (oldestDateInThisSitesHormones, site, b.iterator + 1)
				}
				return (b.oldestDate, b.oldest, b.iterator + 1)
			}).oldest
	}

	private func getOldestHormoneDate(from siteId: UUID) -> Date? {
		var hormones = store.getRelatedHormones(siteId)
		hormones.sort(by: {
			if let d1 = $0.date, let d2 = $1.date {
				return d1 < d2
			}
			return false
		})
		return hormones.tryGet(at: 0)?.date
	}

	private func ensureValidOrdering() {
		var shouldSave = false
		for i in 0..<count {
			var site = sites[i]
			if site.order != i {
				site.order = i
				shouldSave = true
			}
		}
		if shouldSave {
			store.pushLocalChangesToManagedContext(sites, doSave: true)
		}
	}

	private func handleSiteCount() {
		if resetWhenEmpty && sites.count == 0 {
			log.info("No stored sites - resetting to default")
			reset()
			logSites()
		}
	}

	private func resetSitesToDefault() {
		let method = settings.deliveryMethod.value
		let defaultSiteNames = SiteStrings.getSiteNames(for: method)
		let previousCount = sites.count
		assignDefaultProperties(options: defaultSiteNames)
		deleteExtraSitesIfNeeded(previousCount: previousCount, newCount: defaultSiteNames.count)
	}

	private func assignDefaultProperties(options: [String]) {
		for i in 0..<options.count {
			let name = options[i]
			if var site = self[i] {
				setSite(&site, index: i, name: name)
			} else {
				var site = insertNew(name: name, save: false, onSuccess: nil)
				site?.order = i
			}
		}
	}

	private func deleteExtraSitesIfNeeded(previousCount: Int, newCount: Int) {
		if newCount < previousCount {
			deleteSites(start: newCount, end: previousCount - 1)
		}
	}

	private func setSite(_ site: inout Bodily, index: Index, name: String) {
		site.order = index
		site.name = name
		site.imageId = name
	}

	private func deleteSites(start: Index, end: Index) {
		var deleteCount = 0
		for i in start...end {
			if let site = sites.tryGet(at: i) {
				deleteCount += 1
				site.reset()
				store.delete(site)
			}
		}
		for _ in 0...deleteCount - 1 {
			_ = sites.popLast()
		}
	}

	private func logSites() {
		var sitesDescription = "The Site Schedule contains:"
		for site in sites {
			sitesDescription.append("\nSite. Id=\(site.id), Order=\(site.order), Name=\(site.name)")
		}
		if sitesDescription.last != ":" {
			log.info(sitesDescription)
		}
	}
}
