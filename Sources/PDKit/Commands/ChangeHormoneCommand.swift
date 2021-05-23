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
        hormones.setDate(by: hormoneId, with: dateToSet)
        if let site = sites.suggested {
            hormones.setSite(by: hormoneId, with: site)
        }
    }

    public static func createAutoDate(
        hormone: Hormonal?, useStaticTime: Bool, now: NowProtocol?=nil
    ) -> Date {
        let nowDate = now?.now ?? Date()
        if useStaticTime {
            // Use the time of the hormone's date.
            let time = hormone?.date ?? nowDate
            return DateFactory.createDate(on: nowDate, at: time) ?? nowDate
        }
        return nowDate
    }

    private var dateToSet: Date {
        ChangeHormoneCommand.createAutoDate(
            hormone: hormone, useStaticTime: hormones.useStaticExpirationTime, now: now
        )
    }

    private var nowDate: Date {
        now?.now ?? Date()
    }

    private var hormone: Hormonal? {
        hormones[hormoneId]
    }
}
