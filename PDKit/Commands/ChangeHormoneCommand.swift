//
//  PDCommand.swift
//  PDKit
//
//  Created by Juliya Smith on 10/31/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public class ChangeHormoneCommand: PDCommandProtocol {

    private let hormones: HormoneScheduling
    private let sites: SiteScheduling
    private let hormone: Hormonal
    private let now: NowProtocol?

    init(hormones: HormoneScheduling, sites: SiteScheduling, hormone: Hormonal, now: NowProtocol?=nil) {
        self.hormones = hormones
        self.sites = sites
        self.hormone = hormone
        self.now = now
    }

    public func execute() {
        hormones.setDate(by: hormone.id, with: self.now?.now ?? Date())
        if let site = sites.suggested {
            hormones.setSite(by: hormone.id, with: site)
        }
    }
}
