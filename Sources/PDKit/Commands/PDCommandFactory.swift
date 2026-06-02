//
//  PDCommandFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 10/31/20.

import Foundation

public class PDCommandFactory {

    private let hormones: HormoneScheduling
    private let sites: SiteScheduling

    public init(hormones: HormoneScheduling, sites: SiteScheduling) {
        self.hormones = hormones
        self.sites = sites
    }

    public func createChangeHormoneCommand(
        _ hormone: Hormonal, now: NowProtocol?=nil
    ) -> ChangeHormoneCommand {
        ChangeHormoneCommand(
            hormones: hormones,
            sites: sites,
            hormoneId: hormone.id,
            now: now
        )
    }

    /// Change patches to their next suggested site with the current time. When
    /// `onlyDue` is true, only currently-due (expired) patches change; when
    /// false, every patch in the schedule changes. Returns the changed
    /// hormones so callers (UI, Siri) can re-request notifications and refresh
    /// derived state. The selection logic lives here so every entry point —
    /// the "Change all" button and Siri — shares one tested implementation.
    @discardableResult
    public func changeAllHormones(onlyDue: Bool, now: NowProtocol?=nil) -> [Hormonal] {
        sites.reloadContext()
        let targets = hormones.all.filter { onlyDue ? $0.isExpired : true }
        for hormone in targets {
            createChangeHormoneCommand(hormone, now: now).execute()
        }
        return targets
    }

    /// Change the next patch due (the soonest-expiring) to its next suggested
    /// site with the current time. Returns the changed hormone, or nil if there
    /// are no patches. Used by the Siri "change my next patch" intent.
    @discardableResult
    public func changeNextHormone(now: NowProtocol?=nil) -> Hormonal? {
        sites.reloadContext()
        guard let next = hormones.next else { return nil }
        createChangeHormoneCommand(next, now: now).execute()
        return next
    }

    /// Change the patch currently on the site whose name matches `name`
    /// (case-insensitive, whitespace-trimmed) to its next suggested site with
    /// the current time. Returns the changed hormone, or nil if no patch is on
    /// that site. Used by the Siri "change my <site> patch" intent.
    @discardableResult
    public func changeHormone(onSiteNamed name: SiteName, now: NowProtocol?=nil) -> Hormonal? {
        sites.reloadContext()
        let target = normalized(name)
        guard let hormone = hormones.all.first(where: { normalized($0.siteName) == target }) else {
            return nil
        }
        createChangeHormoneCommand(hormone, now: now).execute()
        return hormone
    }

    private func normalized(_ name: SiteName) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
