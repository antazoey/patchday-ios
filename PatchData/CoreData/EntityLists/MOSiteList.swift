//
//  MOSiteList.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class MOSiteList: MOEntityList {

	init(coreDataStack: PDCoreDataWrapping) {
		super.init(coreDataStack, .site)
	}

	func getManagedSite(by id: UUID) -> MOSite? {
		MOEntities.getManagedSite(by: id)
	}

	func getManagedHormone(by id: UUID) -> MOHormone? {
		MOEntities.getManagedHormone(by: id)
	}

	func getManagedSiteData() -> [SiteStruct] {
		if !initialized {
			loadStoredSites()
		}
		return getCurrentManagedSites()
	}

	func createNewManagedSite(doSave: Bool = true) -> SiteStruct? {
		guard let newSite = createNewSite() else {
			logger.errorOnCreation()
			return nil
		}
		if doSave {
			saver.saveCreateNewEntity()
		}
		return newSite
	}

	func pushSiteDataToManagedContext(_ siteData: [SiteStruct], doSave: Bool = true) {
		guard siteData.count > 0 else {
			logger.warnForEmptyPush()
			return
		}
		logger.logPush()
		for data in siteData {
			pushSiteData(data)
		}
		if doSave {
			saver.saveFromPush()
		}
	}

	func deleteManagedSiteData(_ siteData: [SiteStruct], doSave: Bool = true) {
		for data in siteData {
			deleteSite(data)
		}
		if doSave {
			saver.saveFromDelete()
		}
	}

	private func loadStoredSites() {
		if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
			logger.logEntityCount(sites.count)
			MOEntities.siteMOs = sites
			fixSiteIdsIfNeeded()
		} else {
			logger.errorOnLoad()
		}
		initialized = true
	}

	private func getCurrentManagedSites() -> [SiteStruct] {
		var siteStructs: [SiteStruct] = []
		for managedSite in MOEntities.siteMOs {
			if let site = CoreDataEntityAdapter.convertToSiteStruct(managedSite) {
				siteStructs.append(site)
			}
		}
		return siteStructs
	}

	private func fixSiteIdsIfNeeded() {
		for site in MOEntities.siteMOs {
			if site.id == nil {
				site.id = UUID()
			}
		}
	}

	func createNewSite() -> SiteStruct? {
		guard var newManagedSite = coreDataStack.insert(.site) as? MOSite else { return nil }
		initSite(&newManagedSite)
		return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
	}

	private func initSite(_ managedSite: inout MOSite) {
		let id = UUID()
		logger.logCreate(id: id.uuidString)
		managedSite.id = id
		MOEntities.siteMOs.append(managedSite)
	}

	private func pushSiteData(_ siteData: SiteStruct) {
		guard var managedSite = getManagedSite(by: siteData.id) else { return }
		applySiteDataToManagedSite(siteData, &managedSite)
	}

	private func applySiteDataToManagedSite(_ siteData: SiteStruct, _ managedSite: inout MOSite) {
		CoreDataEntityAdapter.applySiteData(siteData, to: &managedSite)
		guard let hormoneIds = siteData.hormoneRelationshipIds else { return }
		relateHormonesToSite(hormoneIds: hormoneIds, managedSite)
	}

	private func relateHormonesToSite(hormoneIds: [UUID], _ managedSite: MOSite) {
		for hormoneId in hormoneIds {
			relateHormoneToSite(hormoneId: hormoneId, managedSite)
		}
	}

	private func relateHormoneToSite(hormoneId: UUID, _ managedSite: MOSite) {
		guard let managedHormone = getManagedHormone(by: hormoneId) else { return }
		// Check if already related
		if let relationship = managedSite.hormoneRelationship {
			if relationship.contains(managedHormone) {
				return
			}
		}
		managedSite.addToHormoneRelationship(managedHormone)
	}

	private func deleteSite(_ siteData: SiteStruct) {
		guard var managedSite = getManagedSite(by: siteData.id) else { return }
		pushBackupSiteNameToHormones(deletedSite: managedSite)
		resetSite(&managedSite)
		coreDataStack.tryDelete(managedSite)
		MOEntities.siteMOs.removeAll(where: { $0.id == managedSite.id })
	}

	private func resetSite(_ managedSite: inout MOSite) {
		managedSite.name = nil
		managedSite.id = nil
		managedSite.imageIdentifier = nil
		managedSite.order = -1
	}

	private func pushBackupSiteNameToHormones(deletedSite: MOSite) {
		if let hormoneSet = deletedSite.hormoneRelationship,
			let hormones = Array(hormoneSet) as? [MOHormone] {
			for hormone in hormones {
				hormone.siteNameBackUp = deletedSite.name
			}
		}
		saver.saveFromPush()
	}
}
