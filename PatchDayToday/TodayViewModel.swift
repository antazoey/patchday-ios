//
//  TodayAppViewModel.swift
//  PatchDayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import PDKit

class TodayViewModel: NSObject {

    private let data: TodayDataDelegate
    private let changeLabel = NSLocalizedString("Change:", comment: "Short label on Today App")
    private let injectLabel = NSLocalizedString("Inject:", comment: "Short label on Today App")

    private let placeholderText = {
        PlaceholderStrings.DotDotDot
    }()

    init(dataDelegate: TodayDataDelegate) {
        self.data = dataDelegate
    }

    convenience override init() {
        self.init(dataDelegate: TodayData())
    }
    
    // MARK: - Public

    var usingPatches: Bool {
        if let method = data.getDeliveryMethod() {
            return method == PickerOptions.getDeliveryMethodString(for: .Patches)
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
            return PDDateFormatter.formatDate(date)
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
            return PDDateFormatter.formatDate(date)
        }
        return placeholderText
    }
}
