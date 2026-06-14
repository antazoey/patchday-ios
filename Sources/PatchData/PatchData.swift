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

    // swiftlint:disable function_body_length
    public override convenience init() {
        let storeDataStackWrapper = CoreDataStackWrapper()
        let hormoneStore = HormoneStore(storeDataStackWrapper)
        let pillStore = PillStore(storeDataStackWrapper)
        let siteStore = SiteStore(storeDataStackWrapper)

        let dataSharer = DataSharer()
        let pillDataSharer = PillDataSharer(baseSharer: dataSharer)
        let kvs: UbiquitousKeyValueStoring = PDUbiquitousKVStore()
        let isSyncEnabled: () -> Bool = {
            UserDefaults.standard.bool(forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue)
        }
        let userDefaultsWriter = UserDefaultsWriter(
            handler: UserDefaultsWriteHandler(
                baseDefaults: PDUserDefaults(),
                dataSharer: dataSharer,
                kvs: kvs,
                isSyncEnabled: isSyncEnabled
            ),
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
            // Local-only iCloud/setup flags aren't reached by settings.reset.
            // Clear them so the first-launch setup sheet reappears and the
            // app-group migration step re-runs cleanly on the next launch.
            let standardDefaults = UserDefaults.standard
            for key in PDLocalSettingsKey.allCases {
                standardDefaults.removeObject(forKey: key.rawValue)
            }
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
                lastTaken: DateFactory.createDate(daysFrom: -1),
                timesTakenToday: "12:02:02,2:03:05",
                lastWakeUp: DateFactory.createDate(daysFrom: -1),
                isCreated: true
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

            let attributes = PillAttributes()
            let dueDate = DateFactory.createDate(byAddingSeconds: 61, to: now)!
            attributes.expirationInterval.value = .EveryDay
            attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([dueDate])
            attributes.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
            attributes.notify = true
            attributes.timesTakenToday = ""
            attributes.name = "Notification Test"
            pills.set(at: 0, with: attributes)
        }

        // ******************************************************
        // Demo state for App Store / TestFlight screenshots:
        // a realistic 2-patch schedule + a couple of pills, with
        // dates set so the screen looks "in use" but nothing is
        // actively expiring during the capture.
        // ******************************************************
        if PDCli.isDemoState() {
            let now = Date()
            settings.setQuantity(to: 2)
            settings.setNotifications(to: true)
            settings.setUseStaticExpirationTime(to: true)

            // Patch 1: applied 96 hours ago — past the default 84-hour
            // TwiceWeekly interval, so it shows as expired (red text)
            // with a real Right Glute image rendered.
            let allSites = sites.all
            if allSites.count >= 1, let fourDaysAgo = DateFactory.createDate(byAddingHours: -96, to: now) {
                hormones.setSite(at: 0, with: allSites[0])
                hormones.setDate(at: 0, with: fourDaysAgo)
            }
            // Patch 2: applied 24 hours ago at the second site (Left Glute
            // by default). Plenty of cycle left so it reads as "in use."
            if allSites.count >= 2, let oneDayAgo = DateFactory.createDate(byAddingHours: -24, to: now) {
                hormones.setSite(at: 1, with: allSites[1])
                hormones.setDate(at: 1, with: oneDayAgo)
            }

            // Pill 0 (T-Blocker): overdue. lastTaken is 26 hours ago at
            // 8 AM, current time is past 8 AM today → the Pills row
            // flags it as due (red "Due:" text).
            let overdueTBlocker = PillAttributes(
                name: "T-Blocker",
                expirationIntervalSetting: .EveryDay,
                xDays: "",
                times: "08:00:00",
                notify: true,
                lastTaken: DateFactory.createDate(byAddingHours: -26, to: now),
                timesTakenToday: "",
                lastWakeUp: DateFactory.createDate(byAddingHours: -26, to: now),
                isCreated: true
            )
            pills.set(at: 0, with: overdueTBlocker)

            // Pill 1 (Progesterone): taken on time at 8 AM this morning so
            // the screen shows the contrast — one due, one not.
            let onTimeProg = PillAttributes(
                name: "Progesterone",
                expirationIntervalSetting: .EveryDay,
                xDays: "",
                times: "08:00:00",
                notify: true,
                lastTaken: DateFactory.createDate(byAddingHours: -2, to: now),
                timesTakenToday: PDDateFormatter.formatInternalTime(
                    DateFactory.createDate(byAddingHours: -2, to: now) ?? now
                ),
                lastWakeUp: now,
                isCreated: true
            )
            if pills.count > 1 {
                pills.set(at: 1, with: onTimeProg)
            }
        }
        #endif
        Self.seed40DefaultsIfNeeded(settings: settings)
        Self.forceInitialCloudExportIfNeeded(
            hormones: hormones, pills: pills, sites: sites
        )
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

    /// One-time migration that runs on the first launch after updating to 4.0.
    ///
    /// 4.0 changes the default for `useStaticExpirationTime` from `false`
    /// (dynamic) to `true` (static). For users upgrading from 3.x who never
    /// touched the toggle, we preserve their original 3.x behavior so their
    /// schedule doesn't silently shift. For brand-new 4.0 installs, the new
    /// default applies.
    ///
    /// `MentionedDisclaimer` is used as the upgrade discriminator — 3.x users
    /// dismissed the disclaimer alert, setting it to `true`; brand-new
    /// installs have it `false` (or never set).
    private static func seed40DefaultsIfNeeded(settings: SettingsManaging) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: PDLocalSettingsKey.didSeed40Defaults.rawValue) else {
            return
        }
        defaults.set(true, forKey: PDLocalSettingsKey.didSeed40Defaults.rawValue)

        // Only seed if the user hasn't explicitly set this setting.
        let key = PDSetting.UseStaticExpirationTime.rawValue
        if defaults.object(forKey: key) == nil {
            let isUpgrader = settings.mentionedDisclaimer.value
            // 3.x default (false / dynamic) for upgraders;
            // 4.0 default (true / static) for fresh installs.
            settings.setUseStaticExpirationTime(to: !isUpgrader)
        }
    }

    /// One-time migration that runs on the first launch after the update
    /// that introduced reliable iCloud sync.
    ///
    /// Records created before iCloud sync existed (which added persistent-
    /// history tracking + CloudKit) carry no history transaction, so
    /// `NSPersistentCloudKitContainer` never exports them — the data sits on
    /// the origin device while every other device stays empty. Re-saving each
    /// record generates a fresh history transaction, which CloudKit then
    /// exports. Without this, the only workaround is the user manually editing
    /// every patch/pill/site by hand.
    ///
    /// Runs once (guarded by `didForceInitialCloudExport`), silently, and only
    /// when iCloud sync is on and this device actually has local records to
    /// upload. On a fresh install awaiting CloudKit import there's nothing to
    /// push, so we just mark the migration done — that way we never re-export
    /// records that arrived *from* iCloud.
    static func forceInitialCloudExportIfNeeded(
        hormones: HormoneScheduling,
        pills: PillScheduling,
        sites: SiteScheduling,
        cloudSyncEnabled: Bool = CoreDataStack.isCloudSyncEnabledAtLaunch,
        defaults: UserDefaults = .standard
    ) {
        guard cloudSyncEnabled else { return }
        guard !defaults.bool(
            forKey: PDLocalSettingsKey.didForceInitialCloudExport.rawValue
        ) else { return }
        defaults.set(true, forKey: PDLocalSettingsKey.didForceInitialCloudExport.rawValue)

        // Fresh install awaiting import — nothing local to upload.
        guard !hormones.isEmpty else { return }

        PDLog<PatchData>().info("Forcing one-time iCloud re-export of pre-sync records")
        hormones.saveAll()
        pills.saveAll()
        sites.saveAll()
    }
    // swiftlint:enable function_body_length

    public var isFresh: Bool {
        hormones.isEmpty && sites.isDefault
    }

    public var totalAlerts: Int {
        hormones.totalExpired + pills.totalDue
    }

    public func shareSuggestedSite() {
        let name = sites.suggested?.name
        let value = (name?.isEmpty == false && name != SiteStrings.NewSite) ? name : nil
        dataSharer.set(value, for: SharedDataKey.NextSuggestedSite.rawValue)
    }

    public func resetAll() {
        hormones.reset()
        pills.reset()
        let newSiteCount = sites.reset()
        settings.reset(defaultSiteCount: newSiteCount)
    }
}
