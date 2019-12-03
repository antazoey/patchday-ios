//
// Created by Juliya Smith on 11/30/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


enum TimeNumber: String {
    case Time1 = "time1"
    case Time2 = "time2"
}

class PillDetailViewModel: CodeBehindDependencies {

    let pill: Swallowable
    static let DefaultViewControllerTitle = VCTitleStrings.pillTitle
    var selections = PillAttributes()

    init(_ pill: Swallowable) {
        self.pill = pill
    }

    var isNewPill: Bool {
        pill.name == PDStrings.PlaceholderStrings.newPill
    }

    var title: String {
        isNewPill ? VCTitleStrings.newPillTitle : VCTitleStrings.editPillTitle
    }

    var startTimePickerTwoTime: Time {
        selections.time2 ?? pill.time2
    }

    var startMinimumTimePickerTwoTime: Time {
        selections.time1 ?? pill.time1
    }

    var time1Text: String {
        DateHelper.format(time: pill.time1)
    }

    var time2Text: String {
        DateHelper.format(time: pill.time2)
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        if let i = providedPillNameSelection.firstIndex(of: name) {
            return i
        }
        return 0
    }

    var providedPillNameSelection: [String] {
        PDStrings.PillTypes.defaultPills + PDStrings.PillTypes.extraPills
    }

    var pillSelectionCount: Int {
        PDStrings.PillTypes.defaultPills.count + PDStrings.PillTypes.extraPills.count
    }

    func save() {
        if let notifications = notifications {
            notifications.cancelDuePillNotification(pill)
            sdk?.pills.set(for: pill, with: selections)
            notifications.requestDuePillNotification(pill)
            tabs?.reflectDuePillBadgeValue()
        }
    }

    func createTimeNumberTypeFromButton(_ button: UIButton) -> TimeNumber {
        if let id = button.restorationIdentifier, let numType = TimeNumber(rawValue: id) {
            return numType
        }
        return TimeNumber.Time1
    }
}
