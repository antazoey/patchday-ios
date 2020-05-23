//
//  PatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PatchData: NSObject, PatchDataSDK {

	override public var description: String {
		"Root object for developing with PatchData."
	}

	let dataSharer: UserDefaultsProtocol
	let coreData: PDCoreDataWrapping
	let hormoneDataSharer: HormoneDataSharing

	public var settings: PDSettingsManaging
	public var hormones: HormoneScheduling
	public var sites: SiteScheduling
	public var pills: PillScheduling

	public init(
		settings: PDSettingsManaging,
		dataSharer: UserDefaultsProtocol,
		hormones: HormoneScheduling,
		pills: PillScheduling,
		sites: SiteScheduling,
		coreData: PDCoreDataWrapping,
		hormoneDataSharer: HormoneDataSharing
	) {
		self.settings = settings
		self.dataSharer = dataSharer
		self.hormones = hormones
		self.pills = pills
		self.sites = sites
		self.coreData = coreData
		self.hormoneDataSharer = hormoneDataSharer
		super.init()
	}

	// Run
	public override convenience init() {
		let storeDataStackWrapper = CoreDataStackWrapper()
		let hormoneStore = HormoneStore(storeDataStackWrapper)
		let pillStore = PillStore(storeDataStackWrapper)
		let siteStore = SiteStore(storeDataStackWrapper)

		let dataSharer = DataSharer()
		let pillDataSharer = PillDataSharer(baseSharer: dataSharer)
		let userDefaultsWriter = UserDefaultsWriter(
			handler: UserDefaultsWriteHandler(dataSharer: dataSharer),
			getSiteCount: { () in siteStore.siteCount }
		)
		let pillScheduleState = PatchData.determinePillScheduleState(
			settings: userDefaultsWriter
		)
		let pills = PillSchedule(
			store: pillStore, pillDataSharer: pillDataSharer, state: pillScheduleState
		)
		let sites = SiteSchedule(store: siteStore, settings: userDefaultsWriter)
		let hormoneDataSharer = HormoneDataSharer(
			baseSharer: dataSharer, sites: sites, settings: userDefaultsWriter
		)
		let hormones = HormoneSchedule(
			store: hormoneStore,
			hormoneDataSharer: hormoneDataSharer,
			settings: userDefaultsWriter
		)
		let settings = PDSettings(
			writer: userDefaultsWriter, hormones: hormones, sites: sites
		)

		// ******************************************************
		// Nuke mode: Resets app like it's fresh
		// ******************************************************
#if DEBUG
		if PDCli.isNukeMode() {
			hormones.reset()
			pills.reset()
			let newSiteCount = sites.reset()
			settings.reset(defaultSiteCount: newSiteCount)
			storeDataStackWrapper.nuke()
			PDCli.clearNukeFlag()
			self.init()
			PDLogLevel = PDLogLevels.DEBUG
			return
		}
		// ******************************************************

		if PDCli.isDebugMode() {
			PDLogLevel = PDLogLevels.DEBUG
		}

		// ******************************************************
		// Notifications testing - a Hormone that expires in 8 seconds, a Pill that expires in 12
		// ******************************************************
		if PDCli.isNotificationsTest() {
			let now = Date()
			let hormoneBuffer = 8
			let expSec = settings.expirationInterval.hours * 60 * 60 - hormoneBuffer
			settings.setNotifications(to: true)
			let date = DateFactory.createDate(byAddingSeconds: -expSec, to: now)
			hormones.setDate(at: 0, with: date!) // Will expire in 1 minute

			var attrs = PillAttributes()
			attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
			attrs.time1 = DateFactory.createDate(byAddingSeconds: 12, to: now)
			attrs.lastTaken = DateFactory.createDate(byAddingHours: -12, to: now)
			attrs.notify = true
			pills.set(at: 0, with: attrs)
		}
#endif

		self.init(
			settings: settings,
			dataSharer: dataSharer,
			hormones: hormones,
			pills: pills,
			sites: sites,
			coreData: storeDataStackWrapper,
			hormoneDataSharer: hormoneDataSharer
		)
	}

	public var isFresh: Bool {
		hormones.isEmpty && sites.isDefault
	}

	public var totalAlerts: Int {
		hormones.totalExpired + pills.totalDue
	}

	private static func determinePillScheduleState(
		settings: UserDefaultsWriting
	) -> PillSchedule.PillScheduleState {
		typealias PSS = PillSchedule.PillScheduleState
		return settings.mentionedDisclaimer.value ? PSS.Working: PSS.Initial
	}
}
