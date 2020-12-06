//
//  MOEntites.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class MOEntities {

    static var hormoneMOs: [MOHormone] = []
    static var pillMOs: [MOPill] = []
    static var siteMOs: [MOSite] = []

    static func getManagedHormone(by id: UUID) -> MOHormone? {
        guard let hormone = hormoneMOs.first(where: { h in h.id == id }) else { return nil }
        return hormone
    }

    static func getManagedPill(by id: UUID) -> MOPill? {
        guard let pill = MOEntities.pillMOs.first(where: { p in p.id == id }) else { return nil }
        return pill
    }

    static func getManagedSite(by id: UUID) -> MOSite? {
        guard let site = MOEntities.siteMOs.first(where: { s in s.id == id }) else { return nil }
        return site
    }
}
