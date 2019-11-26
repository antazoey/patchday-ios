//
//  HormoneCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    public func load(codeBehind: HormonesCodeBehind, hormone: Hormonal, hormoneIndex: Index) {
        backgroundColor = app?.styles.theme[.bg]
        setThemeColors(at: hormoneIndex)
        if let sdk = app?.sdk {
            let quantity = sdk.defaults.quantity
            if hormoneIndex < quantity.rawValue && hormoneIndex >= 0 {
                let theme = sdk.defaults.theme.value
                let method = sdk.defaults.deliveryMethod.value
                let siteImage = PDImages.getImage(
                    for: hormone, theme: theme, deliveryMethod: method
                )
                let cellTitle = ColonedStrings.getDateTitle(
                    for: hormone, method: method
                )
                configureDate(when: isExpired)
                configureBadge(at: index, isExpired: hormone.isExpired, deliveryMethod: method)
                setDateLabel(cellTitle)
                if sdk.state.didStaChange(for: hormone) {
                    animate(at: index, theme: theme, newImage: siteImage, newTitle: cellTitle)
                } else {
                    stateImage.image = siteImage
                }
                selectionStyle = .default
                stateImage.isHidden = false
        } else if index >= quantity.rawValue && index <= 3 {
            animate(at: index, theme: data.theme)
        } else {
            reset()
        }
        }
    }
    
    /// Animates drawing hormone button
    private func animate(
        at index: Index,
        theme: PDTheme,
        newImage: UIImage?=nil,
        newTitle: String?=nil
    ) {
        UIView.transition(
            with: stateImage as UIView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.stateImage.image = newImage },
            completion: nil
        )
    }
    
    private func setDateLabel(_ title: String?) {
        self.dateLabel.textColor = app?.styles.theme[.text]
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
        if let styles = app?.styles {
            selectedBackgroundView?.backgroundColor = styles.theme[.selected]
            backgroundColor = styles.getCellColor(at: index)
        }
    }

    private func configureDate(when isExpired: Bool) {
        dateLabel.textColor = isExpired ? UIColor.red : UIColor.black
        let size: CGFloat = AppDelegate.isPad ? 38.0 : 15.0
        dateLabel.font = UIFont.systemFont(ofSize: size)
    }

    private func configureBadge(at index: Int, isExpired: Bool, deliveryMethod: DeliveryMethod) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.type = deliveryMethod == DeliveryMethod.Injections
            ? PDBadgeButtonType.injections
            : PDBadgeButtonType.patches
        badgeButton.badgeValue = isExpired ? "!" : nil
    }
}
