//
//  PillSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PillSchedule: NSObject, PillScheduling {

	override public var description: String { "Schedule for pills." }

	private lazy var log = PDLog<PillSchedule>()

	private var pills: [Swallowable]
	private let store: PillStoring
	private let sharer: PillDataSharing

	enum PillScheduleState {
		case Initial
		case Working
	}

	init(store: PillStoring, pillDataSharer: PillDataSharing, state: PillScheduleState) {
		self.store = store
		self.sharer = pillDataSharer
		self.pills = store.getStoredPills()
		super.init()
		if state == .Initial {
			log.info("Pill state is initial - Setting up default Pills")
			self.reset()
		}
		awaken()
	}

	public var all: [Swallowable] { pills }

	public var count: Int { pills.count }

	public subscript(id: UUID) -> Swallowable? {
		pills.first(where: { p in p.id == id })
	}

	public subscript(index: Index) -> Swallowable? {
		pills.tryGet(at: index)
	}

	public var nextDue: Swallowable? {
		pills.min {
			switch($0.due, $1.due) {
				case (nil, nil): return false
				case (nil, _): return false
				case (_, nil): return true
				default: return $0.due! < $1.due!
			}
		}
	}

	public var totalDue: Int {
		pills.reduce(0) {
			(count: Int, pill: Swallowable) -> Int in
			pill.isDue ? 1 + count : count
		}
	}

	// MARK: - Override base class

	@discardableResult
	public func insertNew(onSuccess: (() -> Void)?) -> Swallowable? {
		if let pill = store.createNewPill() {
			pills.append(pill)
			store.pushLocalChangesToManagedContext([pill], doSave: true)
			onSuccess?()
			shareData()
			return pill
		}
		return nil
	}

	public func delete(at index: Index) {
		if let pill = self[index] {
			pills.remove(at: index)
			store.delete(pill)
			shareData()
		}
	}

	public func reset() {
		deleteAll()
		pills = PillStrings.DefaultPills.reduce([]) {
			(currentPills: [Swallowable], name: String) -> [Swallowable] in
			if var pill = store.createNewPill(name: name) {
				pill.timesaday = 1
				return currentPills + [pill]
			}
			return currentPills
		}
		store.pushLocalChangesToManagedContext(pills, doSave: true)
	}

	public func set(at index: Index, with attributes: PillAttributes) {
		if var pill = self[index] {
			set(&pill, with: attributes)
		}
	}

	public func set(by id: UUID, with attributes: PillAttributes) {
		if var pill = self[id] {
			set(&pill, with: attributes)
		}
	}

	public func swallow(_ id: UUID, onSuccess: (() -> Void)?) {
		if let pill = self[id] {
			swallow(pill, onSuccess) // Saves
		}
	}

	public func swallow(onSuccess: (() -> Void)?) {
		if let pill = nextDue {
			swallow(pill, onSuccess)
		}
	}

	public func indexOf(_ pill: Swallowable) -> Index? {
		pills.firstIndex { (_ p: Swallowable) -> Bool in p.id == pill.id }
	}

	public func shareData() {
		if let next = nextDue {
			sharer.share(nextPill: next)
		}
	}

	// MARK: - Private

	private func set(_ pill: inout Swallowable, with attributes: PillAttributes) {
		pill.set(attributes: attributes)
		store.pushLocalChangesToManagedContext([pill], doSave: true)
		shareData()
	}

	private func awaken() {
		for pill in pills {
			pill.awaken()
		}
		store.pushLocalChangesToManagedContext(pills, doSave: true)
	}

	private func swallow(_ pill: Swallowable, _ onSuccess: (() -> Void)?) {
		if pill.timesTakenToday < pill.timesaday || pill.lastTaken == nil {
			pill.swallow()
			store.pushLocalChangesToManagedContext([pill], doSave: true)
			onSuccess?()
		}
	}

	private func deleteAll() {
		pills.forEach { (_ p: Swallowable) -> Void in store.delete(p) }
		pills = []
	}
}
