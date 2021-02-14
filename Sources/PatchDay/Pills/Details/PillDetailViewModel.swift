//
// Created by Juliya Smith on 11/30/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillDetailViewModel: CodeBehindDependencies<PillDetailViewModel>, PillDetailViewModelProtocol {

    private let _index: Index
    var pill: Swallowable? { sdk?.pills[index] }
    static let DefaultViewControllerTitle = PDTitleStrings.PillTitle
    var selections = PillAttributes()
    private let now: NowProtocol?

    init(_ pillIndex: Index) {
        self._index = pillIndex
        self.now = nil
        super.init()
    }

    init(_ pillIndex: Index, dependencies: DependenciesProtocol, now: NowProtocol?=nil) {
        self._index = pillIndex
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

    var index: Index {
        _index
    }

    var title: String {
        guard let pill = pill else { return "" }
        return pill.isNew ? PDTitleStrings.NewPillTitle : PDTitleStrings.EditPillTitle
    }

    var name: String {
        guard let pill = pill else { return "" }
        return selections.name ?? pill.name
    }

    var nameIsSelected: Bool {
        selections.name != nil
    }

    var nameOptions: [String] {
        PillStrings.DefaultPills + PillStrings.ExtraPills
    }

    var namePickerStartIndex: Index {
        guard let pill = pill else { return 0 }
        return nameOptions.firstIndex(of: selections.name ?? pill.name) ?? 0
    }

    var timesaday: Int {
        times.count
    }

    var timesadayText: String {
        "\(NSLocalizedString("How many per day: ", comment: "Label prefix")) \(timesaday)"
    }

    var expirationInterval: PillExpirationIntervalSetting {
        guard let pill = pill else { return .EveryDay }
        return selections.expirationInterval.value ?? pill.expirationIntervalSetting
    }

    var expirationIntervalText: String {
        PillStrings.Intervals.getStringFromInterval(expirationInterval)
    }

    var expirationIntervalUsesDays: Bool {
        guard let pill = pill else { return false }
        if expirationIntervalIsSelected {
            return selections.expirationInterval.usesXDays
        }
        return pill.expirationInterval.usesXDays
    }

    var daysOn: String {
        guard let pill = pill else { return "" }
        return selections.expirationInterval.daysOn
            ?? pill.expirationInterval.daysOn
            ?? DefaultPillAttributes.xDaysString
    }

    var daysOff: String {
        guard let pill = pill else { return "" }
        return selections.expirationInterval.daysOff
            ?? pill.expirationInterval.daysOff
            ?? DefaultPillAttributes.xDaysString
    }

    var daysOptions: [String] {
        PillExpirationIntervalXDays.daysRange.map({ String($0) })
    }

    var positionOptions: [String] {
        guard expirationInterval == .XDaysOnXDaysOff else { return [] }
        return daysOnePositionOptions + daysTwoPositionOptions
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
        guard expirationInterval == .XDaysOnXDaysOff else { return "" }
        let prefix = NSLocalizedString(
            "Current position:", comment: "Appears on a label, preceeds a numeric variable"
        )
        let suffix = getDaysPositionText(isOn: daysIsOn, position: daysPosition).lowercased()
        return "\(prefix) \(suffix)"
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
        if pickerNumber == 0 {
            return startIndexForPosition
        } else if pickerNumber == 1 {
            return daysOne - 1
        } else if pickerNumber == 2 {
            return daysTwo - 1
        }
        return 1
    }

    var daysSelected: Bool {
        selections.expirationInterval.xDaysValue != nil
    }

    var notify: Bool {
        guard let pill = pill else { return false }
        return selections.notify ?? pill.notify
    }

    var times: [Time] {
        guard let pill = pill else { return [] }
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
        guard let pill = pill else { return }
        notifications?.cancelDuePillNotification(pill)
        sdk?.pills.set(by: pill.id, with: selections)
        notifications?.requestDuePillNotification(pill)
        tabs?.reflectPills()
        selections.reset()
    }

    /// Conditionally saved changes based on alert response.
    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.save()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections.reset()
            if let pill = self.pill, pill.name == PillStrings.NewPill {
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
        guard let pill = pill else { return }
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
            let parts = choice.split(separator: " ")
            guard parts.count > 1 else { return }
            let position = parts[0]
            guard let pos = Int(position) else { return }
            let isOn = choice.contains("on")
            trySelectDaysOne()
            trySelectDaysTwo()
            selections.expirationInterval.xDaysIsOn = isOn
            selections.expirationInterval.xDaysPosition = pos
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
        guard let pill = pill else { return 0 }
        return selections.expirationInterval.daysOne
            ?? pill.expirationInterval.daysOne
            ?? DefaultPillAttributes.xDaysInt
    }

    private var daysTwo: Int {
        guard let pill = pill else { return 0 }
        return selections.expirationInterval.daysTwo
            ?? pill.expirationInterval.daysTwo
            ?? DefaultPillAttributes.xDaysInt
    }

    private var daysIsOn: Bool {
        guard let pill = pill else { return false }
        return selections.expirationInterval.xDaysIsOn
            ?? pill.expirationInterval.xDaysIsOn
            ?? true
    }

    private var daysPosition: Int {
        guard let pill = pill else { return 0 }
        return selections.expirationInterval.xDaysPosition
            ?? pill.expirationInterval.xDaysPosition
            ?? 1
    }

    private var wereChanges: Bool {
        guard let pill = pill else { return false }
        return selections.anyAttributeExists(exclusions: pill.attributes)
            || pill.name == PillStrings.NewPill
    }

    private var startIndexForPosition: Int {
        let pos = "\(daysPosition)"
        var options: [String] = []
        var start = 0
        if daysIsOn {
            options = daysOnePositionOptions
        } else {
            options = daysTwoPositionOptions
            start = daysOne
        }
        let qualifyingPhrase = "\(pos) of"
        return (options.firstIndex(where: { $0.contains(qualifyingPhrase) }) ?? 0) + start
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
        "\(position) of \(max) (\(onOff))"
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

    private var daysOnePositionOptions: [String] {
        var positions: [String] = []
        for i in 1...daysOne {
            positions.append(getDaysOnPositionText(i))
        }
        return positions
    }

    private var daysTwoPositionOptions: [String] {
        var positions: [String] = []
        for i in 1...daysTwo {
            positions.append(getDaysOffPositionText(i))
        }
        return positions
    }
}
