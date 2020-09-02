//
//  HormoneList.swift
//  PatchData
//
//  Created by Juliya Smith on 9/1/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class MOHormoneList: MOEntityList {

	init(coreDataStack: PDCoreDataWrapping) {
		super.init(coreDataStack, .hormone)
	}

	func getManagedHormone(by id: UUID) -> MOHormone? {
		MOEntities.getManagedHormone(by: id)
	}

	func getManagedSite(by id: UUID) -> MOSite? {
		MOEntities.getManagedSite(by: id)
	}

	func getManagedHormoneData() -> [HormoneStruct] {
		if !initialized {
			loadStoredHormones()
		}
		return getCurrentMananagedHormones()
	}

	func createNewManagedHormone(doSave: Bool = true) -> HormoneStruct? {
		guard let newHormone = createNewHormone() else {
			logger.errorOnCreation()
			return nil
		}
		if doSave {
			saver.saveCreateNewEntity()
		}
		return newHormone
	}

	func pushHormoneDataToManagedContext(_ hormoneData: [HormoneStruct], doSave: Bool = true) {
		guard hormoneData.count > 0 else {
			logger.warnForEmptyPush()
			return
		}
		logger.logPush()
		for data in hormoneData {
			pushHormoneData(data)
		}
		if doSave {
			saver.saveFromPush()
		}
	}

	func clearSitesFromHormone(_ hormoneId: UUID) {
		guard let hormone = getManagedHormone(by: hormoneId) else { return }
		hormone.siteRelationship = nil
		saver.saveFromDelete()
	}

	func deleteManagedHormoneData(_ hormoneData: [HormoneStruct], doSave: Bool = true) {
		for data in hormoneData {
			deleteHormone(data)
		}
		if doSave {
			saver.saveFromDelete()
		}
	}

	private func loadStoredHormones() {
		if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
			logger.logEntityCount(hormones.count)
			MOEntities.hormoneMOs = hormones
			fixHormoneIdsIfNeeded()
		} else {
			logger.errorOnCreation()
		}
		initialized = true
	}

	private func getCurrentMananagedHormones() -> [HormoneStruct] {
		var hormoneStructs: [HormoneStruct] = []
		for managedHormone in MOEntities.hormoneMOs {
			if let hormone = CoreDataEntityAdapter.convertToHormoneStruct(managedHormone) {
				hormoneStructs.append(hormone)
			}
		}

		return hormoneStructs
	}

	private func fixHormoneIdsIfNeeded() {
		for hormone in MOEntities.hormoneMOs {
			if hormone.id == nil {
				hormone.id = UUID()
			}
		}
	}

	func createNewHormone() -> HormoneStruct? {
		guard var newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone else { return nil }
		initHormone(&newManagedHormone)
		return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
	}

	private func initHormone(_ managedHormone: inout MOHormone) {
		let id = UUID()
		logger.logCreate(id: id.uuidString)
		managedHormone.id = id
		MOEntities.hormoneMOs.append(managedHormone)
	}

	private func pushHormoneData(_ hormoneData: HormoneStruct) {
		guard var managedHormone = getManagedHormone(by: hormoneData.id) else { return }
		applyHormoneDataToManagedHormone(hormoneData, &managedHormone)
	}

	private func applyHormoneDataToManagedHormone(
		_ hormoneData: HormoneStruct, _ managedHormone: inout MOHormone
	) {
		CoreDataEntityAdapter.applyHormoneData(hormoneData, to: &managedHormone)
		guard let siteId = hormoneData.siteRelationshipId else { return }
		relateSiteToHormone(siteId: siteId, managedHormone)
	}

	private func deleteHormone(_ hormoneData: HormoneStruct) {
		guard var managedHormone = getManagedHormone(by: hormoneData.id) else { return }
		resetHormone(&managedHormone)
		coreDataStack.tryDelete(managedHormone)
		MOEntities.hormoneMOs.removeAll(where: { $0.id == hormoneData.id })
	}

	private func relateSiteToHormone(siteId: UUID, _ managedHormone: MOHormone) {
		guard let hormoneId = managedHormone.id else {
			logger.errorOnMissingId()
			return
		}

		if let managedSite = MOEntities.getManagedSite(by: siteId) {
			logger.logRelateSiteToHormone(siteId: siteId, hormoneId: hormoneId)
			managedHormone.siteRelationship = managedSite
		}
	}

	private func resetHormone(_ managedHormone: inout MOHormone) {
		managedHormone.id = nil
		managedHormone.date = nil
		managedHormone.siteNameBackUp = nil
		managedHormone.siteRelationship = nil
	}
}
