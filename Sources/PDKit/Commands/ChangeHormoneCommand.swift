//
//  ChangeHormoneCommand.swift
//  PDKit
//
//  Created by Juliya Smith on 10/31/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class ChangeHormoneCommand: PDCommandProtocol {

    private let hormones: HormoneScheduling
    private let sites: SiteScheduling
    private let hormoneId: UUID
    private let now: NowProtocol?

    init(
        hormones: HormoneScheduling,
        sites: SiteScheduling,
        hormoneId: UUID,
        now: NowProtocol?=nil
    ) {
        self.hormones = hormones
        self.sites = sites
        self.hormoneId = hormoneId
        self.now = now
    }

    public func execute() {
        hormones.setDate(by: hormoneId, with: self.now?.now ?? Date())
        if let site = sites.suggested {
            hormones.setSite(by: hormoneId, with: site)
        }
    }
}
