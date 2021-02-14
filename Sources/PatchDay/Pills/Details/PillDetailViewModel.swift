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
        nameOptions.firstIndex(of: selections.name ?? pill.name) ?? 0
    }

    var timesaday: Int {
        times.count
    }

    var timesadayText: String {
        "\(NSLocalizedString("How many per day: ", comment: "Label prefix")) \(timesaday)"
    }

    var expirationInterval: PillExpirationIntervalSetting {
        selections.expirationInterval.value ?? pill.expirationIntervalSetting
    }

    var expirationIntervalText: String {
        PillStrings.Intervals.getStringFromInterval(expirationInterval)
    }

    var expirationIntervalUsesDays: Bool {
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
        PillExpirationIntervalXDays.daysRange.map({ String($0) })
    }

    var positionOptions: [String] {
        guard expirationInterval == .XDaysOnXDaysOff else { return [] }

        var positions: [String] = []
        for i in 1...daysOne {
            positions.append(getDaysOnPositionText(i))
        }
        for i in 1...daysTwo {
            positions.append(getDaysOffPositionText(i))
        }

        return positions
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
        return NSLocalizedString("Days off:", comment: "on label")
    }

    var daysPositionText: String {
        getDaysPositionText(isOn: daysIsOn, position: daysPosition)
    }

    var expirationIntervalIsSelected: Bool {
        selections.expirationInterval.value != nil
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
        selections.expirationInterval.xDaysValue != nil
    }

    var notify: Bool {
        selections.notify ?? pill.notify
    }

    var times: [Time] {
        if let selectedTimes = selections.times {
            return DateFactory.createTimesFromCommaSeparatedString(selectedTimes, now: now)
        } else if pill.times.count > 0 {
            let timeString = PDDateFormatter.convertTimesToCommaSeparatedString(pill.times)
            return DateFactory.createTimesFromCommaSeparatedString(timeString, now: now)
        } else {
            return DateFactory.createTimesFromCommaSeparatedString(
                DefaultPillAttributes.time, now: now
            )
        }
    }

    func selectTime(_ time: Time, _ index: Index) {
        var times = self.times
        guard index < times.count && index >= 0 else { return }
        times[index] = time
        selections.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
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
        let newTimeString = PDDateFormatter.convertTimesToCommaSeparatedString(timesCopy)
        selections.times = newTimeString
    }

    func setPickerTimes(_ timePickers: [UIDatePicker]) {
        for i in 0..<timePickers.count {
            let picker = timePickers[i]
            let startTime = times.tryGet(at: i) ?? now?.now ?? Date()
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
            let days = pill.expirationInterval.daysTwo ?? DefaultPillAttributes.xDaysInt
            selections.expirationInterval.daysTwo = days
        }
    }

    func selectFromDaysPicker(_ row: Index, daysNumber: Int?) {
        guard expirationIntervalUsesDays else { return }

        // If selecting a days, have to first select current dependent attributes from pill.
        selections.expirationInterval.value = expirationInterval

        if daysNumber == 1 || daysNumber == 2 {
            guard 0..<daysOptions.count ~= row else { return }
            guard let option = Int(daysOptions[row]) else { return }
            if daysNumber == 1 {
                selections.expirationInterval.daysOne = option
                trySelectDaysTwo()
            } else if daysNumber == 2 {
                trySelectDaysOne()
                selections.expirationInterval.daysTwo = option
            }
        } else if daysNumber == 0 {
            guard let choice = positionOptions.tryGet(at: row) else { return }
            let parts = choice.split(separator: "-")
            let subparts = parts[1].split(separator: "/")
            guard subparts.count == 2 else { return }
            let isOn = parts[0].contains("on")
            let posPart = subparts[0].filter { $0 != " " }
            guard let pos = Int(posPart) else { return }
            trySelectDaysOne()
            trySelectDaysTwo()
            selections.expirationInterval.xDaysIsOn = isOn
            selections.expirationInterval.xDaysPosition = pos
        }
    }

    private func trySelectDaysOne() {
        if selections.expirationInterval.daysOne == nil {
            selections.expirationInterval.daysOne = daysOne
        }
    }

    private func trySelectDaysTwo() {
        if expirationInterval == .XDaysOnXDaysOff {
            selections.expirationInterval.daysTwo = daysTwo
        }
    }

    func getOptionsForSelectedPicker(_ pickerNumber: Int) -> [String] {
        // Setting a days prop
        if pickerNumber == 1 || pickerNumber == 2 {
            return daysOptions
        } else if pickerNumber == 0 {
            // Settings the pos
            return positionOptions
        }
        return []
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

    private var daysIsOn: Bool {
        selections.expirationInterval.xDaysIsOn
            ?? pill.expirationInterval.xDaysIsOn
            ?? true
    }

    private var daysPosition: Int {
        selections.expirationInterval.xDaysPosition
            ?? pill.expirationInterval.xDaysPosition
            ?? 1
    }

    private var wereChanges: Bool {
        selections.anyAttributeExists(exclusions: pill.attributes)
            || pill.name == PillStrings.NewPill
    }

    private func getDaysPositionText(isOn: Bool, position: Int) -> String {
        guard expirationInterval == .XDaysOnXDaysOff else { return "" }
        return isOn ? getDaysOnPositionText(position) : getDaysOffPositionText(position)
    }

    private func getDaysOnPositionText(_ position: Int) -> String {
        getDaysPositionText("on", daysOne, position)
    }

    private func getDaysOffPositionText(_ position: Int) -> String {
        getDaysPositionText("off", daysTwo, position)
    }

    private func getDaysPositionText(_ onOff: String, _ max: Int, _ position: Int) -> String {
        "\(NSLocalizedString("Days \(onOff)", comment: "Part of label")) - \(position)/\(max)"
    }
}
