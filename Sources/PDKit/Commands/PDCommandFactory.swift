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
}
