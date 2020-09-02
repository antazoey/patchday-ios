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
		if let hormone = hormoneMOs.first(where: { h in h.id == id }) {
			return hormone
		}
		return nil
	}

	static func getManagedPill(by id: UUID) -> MOPill? {
		if let pill = MOEntities.pillMOs.first(where: { p in p.id == id }) {
			return pill
		}
		return nil
	}

	static func getManagedSite(by id: UUID) -> MOSite? {
		if let site = MOEntities.siteMOs.first(where: { s in s.id == id }) {
			return site
		}
		return nil
	}
}
