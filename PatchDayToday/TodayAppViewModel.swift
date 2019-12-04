//
//  TodayAppViewModel.swift
//  PatchDayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import PDKit

class TodayAppViewModel: NSObject {

    private let data: TodayAppDataDelegate
    private let changeLabel = NSLocalizedString("Change:", comment: "Short label on Today App")
    private let injectLabel = NSLocalizedString("Inject:", comment: "Short label on Today App")

    private let placeholderText = {
        PDStrings.PlaceholderStrings.dotDotDot
    }()

    init(dataDelegate: TodayAppDataDelegate) {
        self.data = dataDelegate
    }

    convenience override init() {
        self.init(dataDelegate: TodayAppData())
    }
    
    // MARK: - Public

    var usingPatches: Bool {
        if let method = data.getDeliveryMethod() {
            return method == NSLocalizedString("Patches", comment: "duplicate")
        }
        return false
    }

    var hormoneTitle: String {
        usingPatches ? changeLabel : injectLabel
    }

    var hormoneSiteName: String {
        let hormone = PDTStructFactory.createHormone(data)
        return hormone.siteName ?? placeholderText
    }

    var hormoneDateText: String {
        let hormone = PDTStructFactory.createHormone(data)
        if let date = hormone.date {
            return DateHelper.format(date: date, useWords: true)
        }
        return placeholderText
    }

    var nextPillName: String {
        let pill = PDTStructFactory.createPill(data)
        return pill.name ?? placeholderText
    }

    var nextPillDateText: String {
        let pill = PDTStructFactory.createPill(data)
        if let date = pill.nextTakeDate {
            return DateHelper.format(date: date, useWords: true)
        }
        return placeholderText
    }
}
