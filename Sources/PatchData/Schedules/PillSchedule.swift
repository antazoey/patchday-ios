//
//  PillSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.

import Foundation
import CoreData
import PDKit

public class PillSchedule: NSObject, PillScheduling {

    override public var description: String { "Schedule for pills." }

    private lazy var log = PDLog<PillSchedule>()

    private let store: PillStoring
    private let sharer: PillDataSharing
    private var context: [Swallowable]

    init(store: PillStoring, pillDataSharer: PillDataSharing) {
        self.store = store
        self.sharer = pillDataSharer
        self.context = store.getStoredPills()
        super.init()
        if store.state == .Initial {
            log.info("Pill state is initial - Setting up default Pills")
            self.reset()
        }
        awaken()
    }

    public var all: [Swallowable] { context }

    public var count: Int { all.count }

    public subscript(id: UUID) -> Swallowable? {
        all.first(where: { p in p.id == id })
    }

    public subscript(index: Index) -> Swallowable? {
        all.tryGet(at: index)
    }

    public var nextDue: Swallowable? {
        all.min {
            switch($0.due, $1.due) {
                case (nil, nil): return false
                case (nil, _): return false
                case (_, nil): return true
                default: return $0.due! < $1.due!
            }
        }
    }

    public var totalDue: Int {
        all.reduce(0) {
            (count: Int, pill: Swallowable) -> Int in
            pill.isDue ? 1 + count : count
        }
    }

    public func reloadContext() {
        self.context = store.getStoredPills()
    }

    // MARK: - Override base class

    @discardableResult
    public func insertNew(onSuccess: (() -> Void)?) -> Swallowable? {
        guard var pill = store.createNewPill() else { return nil }
        pill.notify = true
        context.append(pill)
        store.pushLocalChangesToManagedContext([pill], doSave: true)
        onSuccess?()
        shareData()
        return pill
    }

    public func delete(at index: Index) {
        guard let pill = self[index] else { return }
        context.remove(at: index)
        store.delete(pill)
        shareData()
    }

    public func reset() {
        deleteAll()
        context = PillStrings.DefaultPills.reduce([]) {
            (currentPills: [Swallowable], name: String) -> [Swallowable] in
            if var pill = store.createNewPill(name: name) {
                pill.notify = true
                pill.appendTime(Date())
                return currentPills + [pill]
            }
            return currentPills
        }
        store.pushLocalChangesToManagedContext(context, doSave: true)
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        guard var pill = self[index] else { return }
        set(&pill, with: attributes)
    }

    public func set(by id: UUID, with attributes: PillAttributes) {
        guard var pill = self[id] else { return }
        set(&pill, with: attributes)
    }

    public func swallow(_ id: UUID, onSuccess: (() -> Void)?) {
        guard let pill = self[id] else { return }
        swallow(pill, onSuccess) // Saves
    }

    public func swallow(onSuccess: (() -> Void)?) {
        guard let pill = nextDue else { return }
        swallow(pill, onSuccess)
    }

    public func indexOf(_ pill: Swallowable) -> Index? {
        all.firstIndex { (_ p: Swallowable) -> Bool in p.id == pill.id }
    }

    public func shareData() {
        guard let next = nextDue else { return }
        sharer.share(nextPill: next)
    }

    // MARK: - Private

    private func set(_ pill: inout Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        store.pushLocalChangesToManagedContext([pill], doSave: true)
        shareData()
    }

    /// Awaken the properties that are relevant to the current date and time.
    private func awaken() {
        for pill in all {
            pill.awaken()
        }
        store.pushLocalChangesToManagedContext(all, doSave: true)
    }

    private func swallow(_ pill: Swallowable, _ onSuccess: (() -> Void)?) {
        guard pill.timesTakenToday < pill.timesaday || pill.lastTaken == nil else { return }
        pill.swallow()
        store.pushLocalChangesToManagedContext([pill], doSave: true)
        onSuccess?()
        shareData()
    }

    private func deleteAll() {
        context.forEach { (_ p: Swallowable) -> Void in store.delete(p) }
        context = []
    }
}
