//
//  PillDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillDetailViewModelProtocol {
    var index: Index { get }
    var pill: Swallowable { get }
    var selections: PillAttributes { get set }
    var title: String { get }
    var name: String { get }
    var expirationInterval: PillExpirationInterval { get }
    var expirationIntervalText: String { get }
    var timesaday: Int { get }
    var namePickerStartIndex: Index { get }
    var expirationIntervalStartIndex: Index { get }
    var notify: Bool { get }
    var providedNameSelection: [String] { get }
    var nameSelectionCount: Int { get }
    var times: [Time] { get }
    func selectTime(_ time: Time, _ index: Index)
    func setTimesaday(_ timesaday: Int)
    func getPickerTimes(timeIndex: Index) -> (start: Time, min: Time?)
    func save()
    func handleIfUnsaved(_ viewController: UIViewController)
    func selectNameFromRow(_ row: Index)
    func selectExpirationIntervalFromRow(_ row: Index)
    func enableOrDisablePickers(_ pickers: [UIDatePicker])
    func assignTimePickerMinsAndMaxes(_ picker: [UIDatePicker])
}
