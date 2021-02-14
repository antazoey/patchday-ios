//
//  MOEntites.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.

import Foundation
import PDKit

class MOEntities {

    static var hormoneMOs: [MOHormone] = []
    static var pillMOs: [MOPill] = []
    static var siteMOs: [MOSite] = []

    static func getManagedHormone(by id: UUID) -> MOHormone? {
        hormoneMOs.first(where: { h in h.id == id })
    }

    static func getManagedPill(by id: UUID) -> MOPill? {
        MOEntities.pillMOs.first(where: { p in p.id == id })
    }

    static func getManagedSite(by id: UUID) -> MOSite? {
        MOEntities.siteMOs.first(where: { s in s.id == id })
    }
}
