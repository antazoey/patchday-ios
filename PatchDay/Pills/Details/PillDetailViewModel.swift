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

class PillDetailViewModel: CodeBehindDependencies<PillDetailViewModel> {

    let pill: Swallowable
    static let DefaultViewControllerTitle = ViewTitleStrings.PillTitle
    var selections = PillAttributes()

    init(_ pill: Swallowable) {
        self.pill = pill
        super.init()
    }

    var isNewPill: Bool {
        pill.name == PillStrings.NewPill
    }

    var title: String {
        isNewPill ? ViewTitleStrings.NewPillTitle : ViewTitleStrings.EditPillTitle
    }

    var startTimePickerTwoTime: Time {
        selections.time2 ?? pill.time2
    }

    var startMinimumTimePickerTwoTime: Time {
        selections.time1 ?? pill.time1
    }

    var time1Text: String {
        PDDateFormatter.formatTime(pill.time1)
    }

    var time2Text: String {
        PDDateFormatter.formatTime(pill.time2)
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        if let i = providedPillNameSelection.firstIndex(of: name) {
            return i
        }
        return 0
    }

    var providedPillNameSelection: [String] {
        PillStrings.PillTypes.defaultPills + PillStrings.PillTypes.extraPills
    }

    var pillSelectionCount: Int {
        PillStrings.PillTypes.defaultPills.count + PillStrings.PillTypes.extraPills.count
    }

    func save() {
        if let notifications = notifications {
            notifications.cancelDuePillNotification(pill)
            sdk?.pills.set(by: pill.id, with: selections)
            notifications.requestDuePillNotification(pill)
            tabs?.reflectDuePillBadgeValue()
        }
    }

    /// Sets the selected name with the name at the given index and optionally returns the name.
    @discardableResult
    func selectNameFromRow(_ row: Index) -> String {
        selections.name = providedPillNameSelection[row]
        return providedPillNameSelection[row]
    }

    func createTimeNumberTypeFromButton(_ button: UIButton) -> TimeNumber {
        if let id = button.restorationIdentifier, let numType = TimeNumber(rawValue: id) {
            return numType
        }
        return TimeNumber.Time1
    }

    func setSelectedTimesadayFromSliderValue(sliderValue: Float) {
        selections.timesaday = TimesadaySliderDefinition.convertSliderValueToTimesaday(sliderValue: sliderValue)
    }

    func sliderValueRepresentsPlurality(sliderValue: Float) -> Bool {
        sliderValue >= 2.0
    }
}
