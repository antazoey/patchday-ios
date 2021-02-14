//
//  PDCommandFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 10/31/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

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
}
