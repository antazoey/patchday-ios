//
// Created by Juliya Smith on 11/30/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillDetailViewModel: CodeBehindDependencies<PillDetailViewModel>, PillDetailViewModelProtocol {

    let index: Index
    var pill: Swallowable {
        sdk!.pills[index]!
    }
    static let DefaultViewControllerTitle = PDTitleStrings.PillTitle
    var selections: PillAttributes = PillAttributes()
    private let now: NowProtocol?

    init(_ pillIndex: Index) {
        self.index = pillIndex
        self.now = nil
        super.init()
    }

    init(_ pillIndex: Index, dependencies: DependenciesProtocol, now: NowProtocol?=nil) {
        self.index = pillIndex
        self.now = now
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

    var name: String {
        selections.name ?? pill.name
    }

    var nameIsSelected: Bool {
        selections.name != nil
    }

    var nameOptions: [String] {
        PillStrings.DefaultPills + PillStrings.ExtraPills
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        return nameOptions.firstIndex(of: name) ?? 0
    }

    var timesaday: Int {
        times.count
    }

    var timesadayText: String {
        "\(NSLocalizedString("How many per day: ", comment: "Label prefix")) \(timesaday)"
    }

    var expirationInterval: PillExpirationIntervalSetting {
        selections.expirationIntervalSetting ?? pill.expirationIntervalSetting
    }

    var expirationIntervalText: String {
        PillStrings.Intervals.getStringFromInterval(expirationInterval)
    }

    var expirationIntervalUsesDays: Bool {
        // TODO: Add tests
        if expirationIntervalIsSelected {
            return selections.expirationInterval.usesXDays
        }
        return pill.expirationInterval.usesXDays
    }

    var daysOn: String {
        selections.expirationInterval.daysOn
            ?? pill.expirationInterval.daysOn
            ?? DefaultPillAttributes.xDaysString
    }

    var daysOff: String {
        selections.expirationInterval.daysOff
            ?? pill.expirationInterval.daysOff
            ?? DefaultPillAttributes.xDaysString
    }

    var daysOptions: [String] {
        PillExpirationInterval.daysRange.map({ String($0) })
    }

    var daysOneLabelText: String? {
        guard expirationIntervalUsesDays else { return nil }
        if expirationInterval == .FirstXDays {
            return NSLocalizedString("First X days of the month:", comment: "on label")
        } else if expirationInterval == .LastXDays {
            return NSLocalizedString("Last X days of the month:", comment: "on label")
        }
        return NSLocalizedString("Days on:", comment: "on label")
    }

    var daysTwoLabelText: String? {
        guard expirationInterval == .XDaysOnXDaysOff else { return nil }
        // .XDaysOnXDaysOff
        return NSLocalizedString("Days off:", comment: "on label")
    }

    var expirationIntervalIsSelected: Bool {
        selections.expirationIntervalSetting != nil
    }

    var expirationIntervalStartIndex: Index {
        PillExpirationInterval.options.firstIndex(of: expirationInterval) ?? 0
    }

    var expirationIntervalOptions: [String] {
        PillStrings.Intervals.all
    }

    func getStartIndexForDaysPicker(pickerNumber: Int) -> Index {
        pickerNumber == 1 ? daysOne - 1 : daysTwo - 1
    }

    var daysSelected: Bool {
        selections.xDays != nil
    }

    var notify: Bool {
        selections.notify ?? pill.notify
    }

    var times: [Time] {
        if let selectedTimes = selections.times {
            return DateFactory.createTimesFromCommaSeparatedString(selectedTimes, now: now)
        }
        // Sort, in case Swallowable impl doesn't
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(pill.times)
        return DateFactory.createTimesFromCommaSeparatedString(timeString, now: now)
    }

    func selectTime(_ time: Time, _ index: Index) {
        var times = self.times
        guard index < times.count && index >= 0 else { return }
        times[index] = time
        selections.times = PDDateFormatter.convertDatesToCommaSeparatedString(times)
    }

    func setTimesaday(_ timesaday: Int) {
        guard timesaday <= MaxPillTimesaday else { return }
        guard timesaday > 0 else { return }
        guard timesaday != self.timesaday else { return }
        var timesCopy = times
        if timesaday > self.timesaday {
            // Set new times to have latest time
            for i in self.timesaday..<timesaday {
                timesCopy.append(times[i-1])
            }
        } else {
            for _ in timesaday..<self.timesaday {
                timesCopy.removeLast()
            }
        }
        let newTimeString = PDDateFormatter.convertDatesToCommaSeparatedString(timesCopy)
        selections.times = newTimeString
    }

    func setPickerTimes(_ timePickers: [UIDatePicker]) {
        for i in 0..<timePickers.count {
            let picker = timePickers[i]
            let startTime = times.tryGet(at: i) ?? Date()
            picker.setDate(startTime, animated: false)
        }
    }

    func save() {
        notifications?.cancelDuePillNotification(pill)
        sdk?.pills.set(by: pill.id, with: selections)
        notifications?.requestDuePillNotification(pill)
        tabs?.reflectPills()
        selections.reset()
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.save()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections.reset()
            if self.pill.name == PillStrings.NewPill {
                self.sdk?.pills.delete(at: self.index)
            }
            self.nav?.pop(source: viewController)
        }
        if wereChanges {
            self.alerts?.createUnsavedAlert(
                viewController,
                saveAndContinueHandler: save,
                discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    func selectName(_ row: Index) {
        let name = nameOptions.tryGet(at: row)
        selections.name = name
    }

    func selectExpirationInterval(_ row: Index) {
        let rowString = PillStrings.Intervals.all.tryGet(at: row) ?? PillStrings.Intervals.all[0]
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = PillStrings.Intervals.getIntervalFromString(rowString) ?? defaultInterval
        selections.expirationInterval.value = interval

        guard PillExpirationInterval.options.contains(interval) else { return }
        if selections.expirationInterval.daysOne == nil {
            let days = pill.expirationInterval.daysOne ?? DefaultPillAttributes.xDaysInt
            selections.expirationInterval.daysOne = days
        }
        if interval == .XDaysOnXDaysOff && selections.expirationInterval.daysTwo == nil {
            let days = pill.expirationInterval.daysOne ?? DefaultPillAttributes.xDaysInt
            selections.expirationInterval.daysTwo = days
        }
    }

    func selectDays(_ row: Index, daysNumber: Int?) {
        guard expirationIntervalUsesDays else { return }
        guard (0..<daysOptions.count) ~= row else { return }
        guard let option = Int(daysOptions[row]) else { return }

        // Make sure interval i set prior to setting xDays
        let currentInterval = selections.expirationIntervalSetting
        selections.expirationInterval.value = currentInterval ?? pill.expirationIntervalSetting

        if daysNumber == 1 {
            selections.expirationInterval.daysOne = option

            // Make sure daysTwo is set if not yet and is used.
            if selections.expirationInterval.daysTwo == nil
                && selections.expirationIntervalSetting == .XDaysOnXDaysOff {
                selections.expirationInterval.daysTwo = pill.expirationInterval.daysTwo
            }
        } else if daysNumber == 2 {
            selections.expirationInterval.daysTwo = option

            // Make sure daysOne is set if not yet and is used.
            if selections.expirationInterval.daysOne == nil {
                selections.expirationInterval.daysOne = pill.expirationInterval.daysOne
            }
        }
        tprint(selections.xDays)
        tprint(selections.expirationInterval.xDays)
    }

    func enableOrDisable(_ pickers: [UIDatePicker], _ labels: [UILabel]) {
        guard 1...pickers.count ~= timesaday else { return }
        guard 1...labels.count ~= timesaday else { return }
        guard pickers.count == labels.count else { return }
        enablePickers(pickers, labels)
        disablePickers(pickers, labels)
    }

    private func enablePickers(_ pickers: [UIDatePicker], _ labels: [UILabel]) {
        for i in 0...timesaday - 1 {
            pickers[i].isEnabled = true
            labels[i].isEnabled = true
        }
    }

    private func disablePickers(_ pickers: [UIDatePicker], _ labels: [UILabel]) {
        for i in timesaday..<pickers.count {
            pickers[i].isEnabled = false
            labels[i].isEnabled = false
        }
    }

    private var daysOne: Int {
        selections.expirationInterval.daysOne
            ?? pill.expirationInterval.daysOne
            ?? DefaultPillAttributes.xDaysInt
    }

    private var daysTwo: Int {
        selections.expirationInterval.daysTwo
            ?? pill.expirationInterval.daysTwo
            ?? DefaultPillAttributes.xDaysInt
    }

    private var wereChanges: Bool {
        selections.anyAttributeExists(exclusions: pill.attributes)
            || pill.name == PillStrings.NewPill
    }
}
