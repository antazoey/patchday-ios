//
//  PillDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillDetailViewModelProtocol {

    /// The index of the`pill` in the `PillSchedule`.
    var index: Index { get }

    /// The view model's `Pill`.
    var pill: Swallowable { get }

    /// The user selections from the UI.
    var selections: PillAttributes { get set }

    /// The title of the view controller.
    var title: String { get }

    /// Either the selected option, `pill.Name` or some default name.
    var name: String { get }

    /// The user has made a selection in the UI for `name`.
    var nameIsSelected: Bool { get }

    /// The possible selections for `name`.
    var nameOptions: [String] { get }

    /// The index to open at in the `name` picker.
    var namePickerStartIndex: Index { get }

    /// Either the selected option, `Pill.expirationInterval`, or some default.
    var expirationInterval: PillExpirationInterval.Option { get }

    /// The user-facing text representing `expirationInterval`.
    var expirationIntervalText: String { get }

    ///Whether `expirationInterval` uses X Days, like `.FirstXDays` or `.XDaysOnXDaysOff`.
    var expirationIntervalUsesDays: Bool { get }

    /// Whether there is a selection for `expirationInterval`.
    var expirationIntervalIsSelected: Bool { get }

    /// The available options to select for `expirationInterval`.
    var expirationIntervalOptions: [String] { get }

    /// The start index for the `expirationInterval` in the picker.
    var expirationIntervalStartIndex: Index { get }

    /// Either the selected option, `Pill.timeaday`, or the default `timesaday`.
    var timesaday: Int { get }

    /// The user-facing text representing `timeaday`.
    var timesadayText: String { get }

    /// Either the selected option, `pill.notify`, or the default option.
    var notify: Bool { get }

    /// Either the selected options, `pill.times`, or the defaul option.
    var times: [Time] { get }

    /// Set one of the `times` so that can be saved.
    func selectTime(_ time: Time, _ index: Index)

    /// Set `timesaday` so it can be saved to the `pill`.
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

    /// Enable or disable the provided pickers, based on `pill` data.
    func enableOrDisable(_ pickers: [UIDatePicker], _ labels: [UILabel])
}
