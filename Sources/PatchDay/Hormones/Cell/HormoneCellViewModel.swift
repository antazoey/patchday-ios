//
//  HormoneCellViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/15/20.

import Foundation
import PDKit

let HORMONE_CELL_PAD_FONT_SIZE: CGFloat = 30.0
let HORMONE_CELL_PHONE_FONT_SIZE: CGFloat = 16.0

class HormoneCellViewModel: HormoneCellViewModelProtocol {

    let cellIndex: Index
    private let sdk: PatchDataSDK
    private let isPad: Bool

    required init(cellIndex: Index, sdk: PatchDataSDK, isPad: Bool) {
        self.cellIndex = cellIndex
        self.sdk = sdk
        self.isPad = isPad
    }

    var hormone: Hormonal? {
        if cellIndex >= 0 && cellIndex < sdk.settings.quantity.rawValue {
            return sdk.hormones[cellIndex]
        }
        return nil
    }

    var showHormone: Bool {
        hormone != nil
    }

    var moonIcon: UIIcon? {
        guard let hormone = hormone else { return nil }
        if hormone.expiresOvernight && !hormone.isExpired {
            return PDIcons.moonIcon
        }
        return nil
    }

    var badgeId: String {
        String(cellIndex)
    }

    var backgroundColor: UIColor {
        PDColors.Cell[cellIndex]
    }

    var badgeType: PDBadgeButtonType {
        guard let hormone = hormone else { return .forPatchesAndGelHormonesView }
        switch hormone.deliveryMethod {
            case .Injections: return .forInjectionsHormonesView
            case .Patches: return .forPatchesAndGelHormonesView
            case .Gel: return .forPatchesAndGelHormonesView
        }
    }

    var badgeValue: String? {
        guard let hormone = hormone else { return nil }
        let shouldShow = hormone.isPastNotificationTime
        return shouldShow ? "!" : nil
    }

    var dateString: String? {
        guard let hormone = hormone else { return nil }
        guard let expiration = hormone.expiration else { return nil }
        guard !hormone.date.isDefault() else { return nil }
        let prefix = HormoneStrings.create(hormone).expirationText
        let dateString = PDDateFormatter.formatDay(expiration)
        return "\(prefix) \(dateString)"
    }

    var dateFont: UIFont {
        let size: CGFloat = isPad ?
            HORMONE_CELL_PAD_FONT_SIZE : HORMONE_CELL_PHONE_FONT_SIZE
        return UIFont.systemFont(ofSize: size)
    }

    var dateLabelColor: UIColor {
        guard let hormone = hormone else { return PDColors[.Text] }
        return hormone.isPastNotificationTime ? UIColor.red : PDColors[.Text]
    }
}
