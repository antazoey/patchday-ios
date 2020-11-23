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
    var nameIsSelected: Bool { get }
    var nameOptions: [String] { get }
    var namePickerStartIndex: Index { get }
    var expirationInterval: PillExpirationInterval { get }
    var expirationIntervalText: String { get }
    var expirationIntervalIsSelected: Bool { get }
    var expirationIntervalOptions: [String] { get }
    var timesaday: Int { get }
    var timesadayText: String { get }
    var expirationIntervalStartIndex: Index { get }
    var notify: Bool { get }
    var times: [Time] { get }
    func selectTime(_ time: Time, _ index: Index)
    func setTimesaday(_ timesaday: Int)
    func setPickerTimes(_ timePickers: [UIDatePicker])
    func save()
    func handleIfUnsaved(_ viewController: UIViewController)
    func selectName(_ row: Index)
    func selectExpirationInterval(_ row: Index)
    func enableOrDisable(_ pickers: [UIDatePicker])
}
