//
// Created by Juliya Smith on 2/10/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

public class PDObjectLogger {

	/// Sometimes it is just nice to see a PDObject in JSON form.

	public static func logHormone(_ hormone: Hormonal) {
		var dateStr = "null"
		if hormone.date.isDefault() {
			dateStr = "\"\(hormone.date)\""
		}
		var siteIdStr = "null"
		if let siteId = hormone.siteId {
			siteIdStr = "\"\(siteId.uuidString)\""
		}
		var expirationStr = "null"
		if let exp = hormone.expiration {
			expirationStr = "\"\(exp)\""
		}
		let hormoneInfo = """
                          {
                                \"type\": \"\(PDEntity.hormone)\",
                                \"date\": \(dateStr),
                                \"siteId\": \(siteIdStr),
                                \"deliveryMethod\": "\(hormone.deliveryMethod)\",
                                \"expirationIntervalHours\": \(hormone.expirationInterval.hours),
                                \"expiration\": \(expirationStr)
                          }
                          """
		print(hormoneInfo)
	}

	public static func logPill(_ pill: Swallowable) {
		var lastTakenStr: String?
		if let lastTaken = pill.lastTaken {
			lastTakenStr = "\"\(lastTaken)\""
		}
		let pillInfo = """
                       {
                            \"type\": \"\(PDEntity.pill)\",
                            \"name\": \"\(pill.name)\",
                            \"timesTakenToday\": \(pill.timesTakenToday),
                            \"timesaday\": \(pill.timesaday),
                            \"times\": \"\(pill.times)\",
                            \"lastTaken\": \(lastTakenStr ?? "null"),
                            \"notify\": \(pill.notify)
                       }
                       """
		print(pillInfo)
	}

	public static func logSite(_ site: Bodily) {
		var hormoneIdsStr = "[]"
		for i in 0..<site.hormoneIds.count {
			let id = site.hormoneIds[i]
			if hormoneIdsStr == "[]" {
				hormoneIdsStr = "["
			}
			hormoneIdsStr.append("\n\t\t\"" + "\(id.uuidString)\"")
			if i < site.hormoneIds.count - 1 {
				hormoneIdsStr.append(",")
			}
		}
		if hormoneIdsStr != "[]" {
			hormoneIdsStr.append("\n\t]")
		}
		let siteInfo = """
                       {
                            \"type\": \"\(PDEntity.site)\",
                            \"name\": \"\(site.name)\",
                            \"order\": \(site.order),
                            \"hormoneIds\": \(hormoneIdsStr)
                       }
                       """
		print(siteInfo)
	}
}
