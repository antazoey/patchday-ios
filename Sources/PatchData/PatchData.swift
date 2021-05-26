//
//  PatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.

import Foundation
import PDKit

public class PatchData: NSObject, PatchDataSDK {

    override public var description: String {
        "Root object for developing with PatchData."
    }

    let dataSharer: UserDefaultsProtocol
    let coreData: PDCoreDataWrapping
    let hormoneDataSharer: HormoneDataSharing

    public var settings: SettingsManaging
    public var hormones: HormoneScheduling
    public var sites: SiteScheduling
    public var pills: PillScheduling

    public let commandFactory: PDCommandFactory

    public init(
        settings: SettingsManaging,
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
        self.commandFactory = PDCommandFactory(hormones: hormones, sites: sites)
        super.init()
    }

    public override convenience init() {
        let storeDataStackWrapper = CoreDataStackWrapper()
        let hormoneStore = HormoneStore(storeDataStackWrapper)
        let pillStore = PillStore(storeDataStackWrapper)
        let siteStore = SiteStore(storeDataStackWrapper)

        let dataSharer = DataSharer()
        let pillDataSharer = PillDataSharer(baseSharer: dataSharer)
        let userDefaultsWriter = UserDefaultsWriter(
            handler: UserDefaultsWriteHandler(dataSharer: dataSharer),
            siteStore: siteStore
        )
        let hormoneDataSharer = HormoneDataSharer(baseSharer: dataSharer)
        let hormones = HormoneSchedule(
            store: hormoneStore,
            hormoneDataSharer: hormoneDataSharer,
            settings: userDefaultsWriter
        )
        let sites = SiteSchedule(store: siteStore, settings: userDefaultsWriter)
        let settings = Settings(
            writer: userDefaultsWriter, hormones: hormones, sites: sites
        )
        let pills = PillSchedule(
            store: pillStore, pillDataSharer: pillDataSharer, settings: settings
        )

        #if DEBUG
        // ******************************************************
        // Nuke mode: Resets app like it's fresh
        // ******************************************************
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
        // New Day Test - Pills completed yesterday
        // ******************************************************
        else if PDCli.isWakeUpTest() {
            let attributes = PillAttributes(
                name: "Test Pill",
                expirationIntervalSetting: .EveryDay,
                xDays: "",
                times: "12:00:00,2:00:00",
                notify: false,
                lastTaken: DateFactory.createDate(daysFromNow: -1),
                timesTakenToday: "12:02:02,2:03:05"
            )
            pills.set(at: 0, with: attributes)
            PDCli.clearWakeUpFlag()
            self.init()
            PDLogLevel = PDLogLevels.DEBUG
            return
        }

        // ******************************************************
        // Debug mode
        // ******************************************************
        if PDCli.isDebugMode() {
            PDLogLevel = PDLogLevels.DEBUG
        }

        // ******************************************************
        // Notifications testing - a Hormone that expires in 20 seconds, a Pill that expires in 12
        // ******************************************************
        if PDCli.isNotificationsTest() {
            let now = Date()
            let delay = 20
            let seconds = settings.expirationInterval.hours * 60 * 60 - delay
            settings.setNotifications(to: true)
            let date = DateFactory.createDate(byAddingSeconds: -seconds, to: now)
            hormones.setDate(at: 0, with: date!)

            let attrs = PillAttributes()
            let dueDate = DateFactory.createDate(byAddingSeconds: 61, to: now)!
            attrs.expirationInterval.value = .EveryDay
            attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([dueDate])
            attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
            attrs.notify = true
            attrs.timesTakenToday = ""
            attrs.name = "Notification Test"
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

    public func resetAll() {
        hormones.reset()
        pills.reset()
        let newSiteCount = sites.reset()
        settings.reset(defaultSiteCount: newSiteCount)
    }
}
