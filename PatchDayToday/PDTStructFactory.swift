//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation

struct HormoneStruct {
	var siteName: String?
	var date: Date?
}

struct PillStruct {
	var name: String?
	var nextTakeDate: Date?
}

class PDTStructFactory {

	static func createHormone(_ data: TodayDataDelegate) -> HormoneStruct {
		var hormone = HormoneStruct()
		trySetHormoneSiteName(data, hormone: &hormone)
		trySetHormoneDate(data, hormone: &hormone)
		return hormone
	}

	static func createPill(_ data: TodayDataDelegate) -> PillStruct {
		var pill = PillStruct()
		trySetPillNextName(data, pill: &pill)
		trySetPillNextDate(data, pill: &pill)
		return pill
	}

	private static func trySetHormoneSiteName(_ data: TodayDataDelegate, hormone: inout HormoneStruct) {
		if let siteName = data.getNextHormoneSiteName() {
			hormone.siteName = siteName
		}
	}

	private static func trySetHormoneDate(_ data: TodayDataDelegate, hormone: inout HormoneStruct) {
		if let expirationDate = data.getNextHormoneExpirationDate() {
			hormone.date = expirationDate
		}
	}

	private static func trySetPillNextName(_ data: TodayDataDelegate, pill: inout PillStruct) {
		if let name = data.getNextPillName() {
			pill.name = name
		}
	}

	private static func trySetPillNextDate(_ data: TodayDataDelegate, pill: inout PillStruct) {
		if let date = data.getNextPillDate() {
			pill.nextTakeDate = date
		}
	}
}
