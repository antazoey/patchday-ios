//
//  PillSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PDPills: NSObject, PDPillScheduling {
    
    override public var description: String { return "Schedule for pills." }
    
    private var pills: [Swallowable]
    
    init(isFirstInit: Bool) {
        self.pills = PatchData.createPills()
        super.init()
        if isFirstInit { self.reset() }
        awaken()
    }
    
    public var all: [Swallowable] { return pills }
    
    public var count: Int { return pills.count }
    
    public var nextDue: Swallowable? {
        if let pills = pills as? [PDPill] {
            return pills.min(by: <)
        }
        return nil
    }

    public var totalDue: Int {
        return pills.reduce(0, {
            (count: Int, pill: Swallowable) -> Int in
            let r = pill.isDue ? 1 + count : count
            return r
        })
    }
    
    // MARK: - Override base class

    public func insertNew(completion: (() -> ())?) -> Swallowable? {
        if let pill = PDPill.new() {
            pills.append(pill)
            if let comp = completion {
                comp()
            }
            return pill
        }
        return nil
    }

    public func delete(at index: Index) {
        switch index {
        case 0..<pills.count :
            let pill = pills.remove(at: index)
            pill.delete()
            PatchData.save()
        default : return
        }
    }

    public func reset() {
        deleteAll()
        let names = PDStrings.PillTypes.defaultPills
        pills = []
        for i in 0..<names.count {
            if let pill = PatchData.insert(.pill) as? MOPill {
                pills.append(PDPill(pill: pill, name: names[i]))
            }
        }
        PatchData.save()
    }

    // MARK: - Public

    public func at(_ index: Index) -> Swallowable? {
        if index >= 0 && index < pills.count {
            return pills[index]
        }
        return nil
    }

    public func get(for id: UUID) -> Swallowable? {
        for pill in pills {
            if pill.id == id {
                return pill
            }
        }
        return nil
    }

    public func set(at index: Index, with attributes: PillAttributes) {
        if let pill = at(index) {
            set(for: pill, with: attributes)
        }
    }

    public func set(for pill: Swallowable, with attributes: PillAttributes) {
        pill.set(attributes: attributes)
        PatchData.save()
    }

    public func swallow(at index: Index, completion: (() -> ())?) {
        if let pill = at(index) {
            swallow(pill, completion: completion)
        }
    }

    public func swallow(_ pill: Swallowable, completion: (() -> ())?) {
        if pill.timesTakenToday < pill.timesaday {
            pill.swallow()
            PatchData.save()
            if let comp = completion {
                comp()
            }
        }
    }

    public func swallow(completion: (() -> ())? = nil) {
        if let next = nextDue {
            swallow(next, completion: completion)
        }
    }
    
    // MARK: - Private

    private func awaken() {
        for pill in pills {
            pill.awaken()
        }
        PatchData.save()
    }
    
    private func deleteAll() {
        for pill in pills { pill.delete() }
        pills = []
    }
}
