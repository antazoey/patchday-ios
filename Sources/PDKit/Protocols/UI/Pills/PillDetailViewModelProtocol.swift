//
//  PillDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillDetailViewModelProtocol {

    /// The index of the`pill` in the `PillSchedule`.
    var index: Index { get }

    /// The view model's `Pill`.
    var pill: Swallowable? { get }

    /// The user selections from the UI.
    var selections: PillAttributes { get }

    /// The title of the view controller.
    var title: String { get }

    /// Either the selected option, `pill.Name`, or some default name.
    var name: String { get }

    /// Is true if the user has made a selection in the UI for `name`.
    var nameIsSelected: Bool { get }

    /// The possible selections for `name`.
    var nameOptions: [String] { get }

    /// The index to open at in the `name` picker.
    var namePickerStartIndex: Index { get }

    /// Either the selected option, `Pill.expirationInterval`, or some default.
    var expirationInterval: PillExpirationIntervalSetting { get }

    /// The user-facing text representing `expirationInterval`.
    var expirationIntervalText: String { get }

    /// Whether `expirationInterval` uses X Days, like `.FirstXDays` or `.XDaysOnXDaysOff`.
    var expirationIntervalUsesDays: Bool { get }

    /// The first days value for when `expirationIntervalUsesDays`.
    var daysOn: String { get }

    /// The second days value for when `expirationInterval == .XDaysOnXDaysOff`.
    var daysOff: String { get }

    /// The available options for the days pickers.
    var daysOptions: [String] { get }

    /// All the possible combinations of the days position. Only applicable to `.XDaysOnXDaysOff`.
    var positionOptions: [String] { get }

    /// The text to display in the label for the first days selection when `expirationIntervalUsesDays`.
    var daysOneLabelText: String? { get }

    /// The text to display in the label for the second days selection when `expirationInterval == .XDaysOnXDaysOff`.
    var daysTwoLabelText: String? { get }

    /// The text to display on the days position label.
    var daysPositionText: String { get }

    /// Whether there is a selection for `expirationInterval`.
    var expirationIntervalIsSelected: Bool { get }

    /// The available options to select for `expirationInterval`.
    var expirationIntervalOptions: [String] { get }

    /// Get the start index for the days picker.
    func getStartIndexForDaysPicker(pickerNumber: Int) -> Index

    /// Whether or not the days have been selected in the UI.
    var daysSelected: Bool { get }

    /// The start index for the `expirationInterval` picker.
    var expirationIntervalStartIndex: Index { get }

    /// Either the selected option, `Pill.timeaday`, or the default `timesaday`.
    var timesaday: Int { get }

    /// The user-facing text representing `timesaday`.
    var timesadayText: String { get }

    /// Either the selected option, `pill.notify`, or the default option.
    var notify: Bool { get }

    /// Either the selected options, `pill.times`, or the defaul option.
    var times: [Time] { get }

    /// Set one of the `times` so that it can be saved.
    func selectTime(_ time: Time, _ index: Index)

    /// Set `timesaday` so that it can be saved.
    func setTimesaday(_ timesaday: Int)

    /// Set the `times` from an array of time pickers.
    func setPickerTimes(_ timePickers: [UIDatePicker])

    /// Save the selection to the `Pill`.
    func save()

    /// Handle the scenario when the user navigates away before saving.
    func handleIfUnsaved(_ viewController: UIViewController)

    /// Set the value for `name`.
    func selectName(_ row: Index)

    /// Set the value for `expirationInterval`.
    func selectExpirationInterval(_ row: Index)

    /// Select a days value for either `daysOne`, `daysTwo`, or the `position`, depending on the given days number.
    func selectFromDaysPicker(_ row: Index, daysNumber: Int?)

    /// Returns either the days options or the positions options, based on the picker number. [1,2] -> days, 0 -> positions.
    func getOptionsForSelectedPicker(_ pickerNumber: Int) -> [String]

    /// Enable or disable the provided pickers, based on `pill` data.
    func enableOrDisable(_ pickers: [UIDatePicker], _ labels: [UILabel])
}
