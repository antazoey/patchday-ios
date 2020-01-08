//
//  HormoneCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneCell: TableCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    private var styles: Styling?

    @discardableResult
    public func configure(viewModel: HormonesViewModel, hormone: Hormonal, row: Index) -> HormoneCell {
        styles = viewModel.styles
        backgroundColor = styles?.theme[.bg]
        setThemeColors(at: row)
        if let sdk = viewModel.sdk {
            let quantity = sdk.defaults.quantity
            let hormoneCellState = HormoneCell.convertHormoneIndexToCellState(
                row, hormoneLimit: quantity.rawValue
            )
            handleHormoneFromState(hormoneCellState, sdk, hormone, row)
        }
        return self
    }

    private static func convertHormoneIndexToCellState(_ index: Index, hormoneLimit: Int) -> HormoneCellState {
        if index < hormoneLimit && index >= 0 {
            return .Occupied
        } else if index >= hormoneLimit && index <= SupportedHormoneUpperQuantityLimit {
            return .Waiting
        } else {
            return .Empty
        }
    }

    private func handleHormoneFromState(
        _ state: HormoneCellState, _ sdk: PatchDataDelegate, _ hormone: Hormonal, _ hormoneIndex: Index
    ) {
        switch state {
        case .Occupied: appearAsOccupiedState(sdk, hormone, hormoneIndex)
        case .Waiting: appearAsWaitingState(sdk, hormoneIndex)
        case .Empty: reset()
        }
    }

    private func appearAsOccupiedState(_ sdk: PatchDataDelegate, _ hormone: Hormonal, _ hormoneIndex: Index) {
        let method = sdk.defaults.deliveryMethod.value
        loadDateLabel(for: hormone)
        loadBadge(at: hormoneIndex, isExpired: hormone.isExpired, deliveryMethod: method)
        loadSiteComponents(sdk, hormone, hormoneIndex)
        selectionStyle = .default
    }

    private func appearAsWaitingState(_ sdk: PatchDataDelegate, _ hormoneIndex: Index) {
        animate(at: hormoneIndex, theme: sdk.defaults.theme.value)
    }
    
    private func setDateLabel(_ title: String?) {
        self.dateLabel.textColor =  styles?.theme[.text]
        self.dateLabel.text = title
    }

    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        stateImage.image = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func setThemeColors(at index: Int) {
        selectedBackgroundView = UIView()
        if let styles = styles {
            selectedBackgroundView?.backgroundColor = styles.theme[.selected]
            backgroundColor = styles.getCellColor(at: index)
        }
    }

    private func loadDateLabel(for hormone: Hormonal) {
        dateLabel.textColor = hormone.isExpired ? UIColor.red : UIColor.black
        let size: CGFloat = AppDelegate.isPad ? 38.0 : 15.0
        dateLabel.font = UIFont.systemFont(ofSize: size)
        if !hormone.date.isDefault() {
            setDateLabel(DateHelper.format(date: hormone.date, useWords: true))
        }
    }

    private func loadBadge(at index: Int, isExpired: Bool, deliveryMethod: DeliveryMethod) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.type = deliveryMethod == DeliveryMethod.Injections
            ? PDBadgeButtonType.injections : PDBadgeButtonType.patches
        badgeButton.badgeValue = isExpired ? "!" : nil
    }

    private func loadSiteComponents(_ sdk: PatchDataDelegate, _ hormone: Hormonal, _ hormoneIndex: Index) {
        let theme = sdk.defaults.theme.value
        let method = sdk.defaults.deliveryMethod.value
        let siteImageDeterminationParams = SiteImageDeterminationParameters(
            hormone: hormone, deliveryMethod: method, theme: theme
        )
        let siteImage = PDImages.getSiteImage(from: siteImageDeterminationParams)
        let cellTitle = ColonStrings.getDateTitle(for: hormone, method: method)
        if sdk.stateManager.hormoneRecentlyMutated(at: hormoneIndex) {
            animate(at: hormoneIndex, theme: theme, newImage: siteImage, newTitle: cellTitle)
        } else {
            stateImage.image = siteImage
        }
        stateImage.isHidden = false
    }

    private func animate(at index: Index, theme: PDTheme, newImage: UIImage?=nil, newTitle: String?=nil) {
        UIView.transition(
            with: stateImage as UIView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.stateImage.image = newImage },
            completion: nil
        )
    }
}
