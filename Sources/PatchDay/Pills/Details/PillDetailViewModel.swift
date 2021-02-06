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
    var selections = PillAttributes()
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
        selections.expirationInterval ?? pill.expirationIntervalSetting
    }

    var expirationIntervalText: String {
        PillStrings.Intervals.getStringFromInterval(expirationInterval)
    }

    var expirationIntervalUsesDays: Bool {
        // TODO: Add tests
        if expirationIntervalIsSelected {
            return selections.expirationIntervalObject.usesXDays
        }
        return pill.expirationInterval.usesXDays
    }

    var daysOn: String {
        // TODO: Tests
        guard let days = pill.expirationInterval.daysOne else {
            return DefaultPillAttributes.xDaysString
        }
        return String(days)
    }

    var daysOff: String {
        // TODO: Tests
        guard let days = pill.expirationInterval.daysTwo else {
            return DefaultPillAttributes.xDaysString
        }
        return String(days)
    }

    var daysOptions: [String] {
        (1...SupportedPillExpirationIntervalDaysLimit).map({ String($0) })
    }

    var daysOneLabelText: String? {
        // TODO: Add tests
        guard expirationIntervalUsesDays else { return nil }
        if expirationInterval == .FirstXDays {
            return NSLocalizedString("First X days of the month:", comment: "on label")
        } else if expirationInterval == .LastXDays {
            return NSLocalizedString("Last X days of the month:", comment: "on label")
        }
        return NSLocalizedString("Days on:", comment: "on label")
    }

    var daysTwoLabelText: String? {
        // TODO: Add tests
        guard expirationIntervalUsesDays else { return nil }
        // .XDaysOnXDaysOff
        return NSLocalizedString("Days off:", comment: "on label")
    }

    var expirationIntervalIsSelected: Bool {
        selections.expirationInterval != nil
    }

    var expirationIntervalStartIndex: Index {
        PillExpirationInterval.options.firstIndex(of: expirationInterval) ?? 0
    }

    var expirationIntervalOptions: [String] {
        PillStrings.Intervals.all
    }

    var daysOneStartIndex: Index {
        // TODO: Tests
        guard let daysOne = selections.expirationIntervalObject.daysOne else { return  0 }
        return daysOne - 1
    }

    var daysTwoStartIndex: Index {
        // TODO: tests 
        guard let daysTwo = selections.expirationIntervalObject.daysTwo else { return  0 }
        return daysTwo - 1
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

    func selectName(_ row: Index) {
        let name = nameOptions.tryGet(at: row)
        selections.name = name
    }

    func selectExpirationInterval(_ row: Index) {
        let rowString = PillStrings.Intervals.all.tryGet(at: row) ?? PillStrings.Intervals.all[0]
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = PillStrings.Intervals.getIntervalFromString(rowString) ?? defaultInterval
        selections.expirationInterval = interval
    }

    func selectDays(_ row: Index, daysNumber: Int?) {
        // TODO: Add TEsts
        guard expirationIntervalUsesDays else { return }
        guard row >= 0 && row < daysOptions.count else { return }
        guard let option = Int(daysOptions[row]) else { return }
        if daysNumber == 1 {
            selections.setDaysOne(option)
        } else if daysNumber == 2 {
            selections.setDaysTwo(option)
        }
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
}
