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

    let index: Index
    var pill: Swallowable {
        sdk!.pills[index]!
    }
    static let DefaultViewControllerTitle = PDTitleStrings.PillTitle
    var selections = PillAttributes()

    init(_ pillIndex: Index) {
        self.index = pillIndex
        super.init()
    }

    init(_ pillIndex: Index, dependencies: DependenciesProtocol) {
        self.index = pillIndex
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge
        )
    }

    var title: String {
        pill.isNew ? PDTitleStrings.NewPillTitle : PDTitleStrings.EditPillTitle
    }

    var startTimePickerTwoTime: Time {
        //selections.time2 ?? pill.time2
        Date()
    }

    var startMinimumTimePickerTwoTime: Time {
        //selections.time1 ?? pill.time1
        Date()
    }

    var time1Text: String {
        //PDDateFormatter.formatTime(pill.time1)
        ""
    }

    var time2Text: String {
        //PDDateFormatter.formatTime(pill.time2)
        ""
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        return providedPillNameSelection.firstIndex(of: name) ?? 0
    }

    var expirationIntervalStartIndex: Index {
        let interval = selections.expirationInterval ?? pill.expirationInterval
        return PillStrings.Intervals.all.firstIndex(of: interval) ?? 0
    }

    var notifyStartValue: Bool {
        selections.notify ?? pill.notify
    }

    var providedPillNameSelection: [String] {
        PillStrings.DefaultPills + PillStrings.ExtraPills
    }

    var pillSelectionCount: Int {
        PillStrings.DefaultPills.count + PillStrings.ExtraPills.count
    }

    func save() {
        notifications?.cancelDuePillNotification(pill)
        sdk?.pills.set(by: pill.id, with: selections)
        notifications?.requestDuePillNotification(pill)
        tabs?.reflectPills()
        selections = PillAttributes()
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.save()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections = PillAttributes()
            if self.pill.name == PillStrings.NewPill {
                self.sdk?.pills.delete(at: self.index)
            }
            self.nav?.pop(source: viewController)
        }
        if selections.anyAttributeExists || pill.name == PillStrings.NewPill {
            self.alerts?.createUnsavedAlert(
                viewController,
                saveAndContinueHandler: save,
                discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    /// Sets the selected name with the name at the given index and optionally returns the name.
    @discardableResult
    func selectNameFromRow(_ row: Index) -> String {
        let name = providedPillNameSelection.tryGet(at: row)
        selections.name = name
        return name ?? ""
    }

    @discardableResult
    func selectExpirationIntervalFromRow(_ row: Index) -> String {
        let interval = PillStrings.Intervals.all.tryGet(at: row)
        selections.expirationInterval = interval
        return interval ?? ""
    }

    func createTimeNumberTypeFromButton(_ button: UIButton) -> TimeNumber {
        guard let id = button.restorationIdentifier, let numType = TimeNumber(rawValue: id) else {
            return TimeNumber.Time1
        }
        return numType
    }

    func setSelectedTimesadayFromSliderValue(sliderValue: Float) {
        // TODO: - This
        //selections.timesaday = TimesadaySliderDefinition.convertSliderValueToTimesaday(sliderValue: sliderValue)
    }
}
