//
//  MOPillList.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class MOPillList: MOEntityList {

	init(coreDataStack: PDCoreDataWrapping) {
		super.init(coreDataStack, .pill)
	}

	func getManagedPill(by id: UUID) -> MOPill? {
		MOEntities.getManagedPill(by: id)
	}

	func getManagedPillData() -> [PillStruct] {
		if !initialized {
			loadStoredPills()
		}
		return getCurrentManagedPills()
	}

	func createNewManagedPill(doSave: Bool = true) -> PillStruct? {
		createNewManagedPill(name: PillStrings.NewPill, doSave: doSave)
	}

	func createNewManagedPill(name: String, doSave: Bool = true) -> PillStruct? {
		guard var newPill = createNewPill() else {
			logger.errorOnCreation()
			return nil
		}
		newPill.attributes.name = name
		if doSave {
			saver.saveCreateNewEntity()
		}
		return newPill
	}

	func pushPillDataToManagedContext(_ pillData: [PillStruct], doSave: Bool = true) {
		guard pillData.count > 0 else {
			logger.warnForEmptyPush()
			return
		}
		logger.logPush()
		for data in pillData {
			pushPillData(data)
		}
		if doSave {
			saver.saveFromPush()
		}
	}

	func deleteManagedPillData(_ pillData: [PillStruct], doSave: Bool = true) {
		for data in pillData {
			deletePill(data)
		}
		if doSave {
			saver.saveFromDelete()
		}
	}

	private func loadStoredPills() {
		if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
			logger.logEntityCount(pills.count)
			MOEntities.pillMOs = pills
			fixPillIdsIfNeeded()
			migratePillTimesIfNeeded()
		} else {
			logger.errorOnLoad()
		}
		initialized = true
	}

	private func getCurrentManagedPills() -> [PillStruct] {
		var pillStructs: [PillStruct] = []
		for managedPill in MOEntities.pillMOs {
			if let pill = CoreDataEntityAdapter.convertToPillStruct(managedPill) {
				pillStructs.append(pill)
			}
		}
		return pillStructs
	}

	private func fixPillIdsIfNeeded() {
		for pill in MOEntities.pillMOs {
			if pill.id == nil {
				pill.id = UUID()
			}
		}
	}

	private func migratePillTimesIfNeeded() {
		for pill in MOEntities.pillMOs {
			var times: [Date?] = []
			if pill.time1 != nil {
				times.append(pill.time1 as Date?)
			}
			if pill.time2 != nil {
				times.append(pill.time2 as Date?)
			}
			if times != [] {
				logger.logPillMigration()
				let timesString = PDDateFormatter.convertDatesToCommaSeparatedString(times)
				pill.times = timesString
				pill.time1 = nil
				pill.time2 = nil
				saver.saveFromMigration()
			}
		}
	}

	func createNewPill() -> PillStruct? {
		guard var newManagedPill = coreDataStack.insert(.pill) as? MOPill else { return nil }
		initPill(&newManagedPill)
		return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
	}

	private func initPill(_ managedPill: inout MOPill) {
		let id = UUID()
		logger.logCreate(id: id.uuidString)
		managedPill.id = id
		MOEntities.pillMOs.append(managedPill)
	}

	private func pushPillData(_ pillData: PillStruct) {
		guard var managedPill = getManagedPill(by: pillData.id) else { return }
		CoreDataEntityAdapter.applyPillData(pillData, to: &managedPill)
	}

	private func deletePill(_ pillData: PillStruct) {
		guard var managedPill = getManagedPill(by: pillData.id) else { return }
		resetPill(&managedPill)
		coreDataStack.tryDelete(managedPill)
		MOEntities.pillMOs.removeAll(where: { $0.id == pillData.id })
	}

	private func resetPill(_ managedPill: inout MOPill) {
		managedPill.time1 = nil
		managedPill.time2 = nil
		managedPill.id = nil
		managedPill.lastTaken = nil
		managedPill.timesTakenToday = -1
		managedPill.notify = false
		managedPill.timesaday = -1
	}
}
