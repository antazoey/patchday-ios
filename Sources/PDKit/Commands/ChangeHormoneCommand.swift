//
//  ChangeHormoneCommand.swift
//  PDKit
//
//  Created by Juliya Smith on 10/31/20.

import Foundation

public class ChangeHormoneCommand: PDCommandProtocol {

    private let hormones: HormoneScheduling
    private let sites: SiteScheduling
    private let hormoneId: UUID
    private let now: NowProtocol?

    private var nowDate: Date {
        now?.now ?? Date()
    }

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
        hormones.setDate(by: hormoneId, with: nowDate)
        if let site = sites.suggested {
            hormones.setSite(by: hormoneId, with: site)
        }
    }
}
