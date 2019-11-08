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
    
    private var sdk: PatchDataDelegate!

    public var index = -1
    
    public func load(sdk: PatchDataDelegate, hormone: Hormonal) {
        self.sdk = sdk
        let quantity = sdk.defaults.quantity.rawValue
        backgroundColor = app?.styles.theme[.bg]
        setThemeColors(at: index)
        if index < quantity && index >= 0 {
            let method = sdk.defaults.deliveryMethod.value
            let theme = sdk.defaults.theme.value
            if let mone = sdk.hormones.at(index) {
                let isExpired = mone.isExpired
                let siteImage = PDImages.getImage(for: mone, theme: theme, deliveryMethod: method)
                let cellTitle = PDColonedStrings.getDateTitle(for: hormone, method: sdk.deliveryMethod)
                configureDate(when: isExpired)
                configureBadge(at: index, isExpired: isExpired, deliveryMethod: method)
                setDateLabel(cellTitle)
                if sdk.stateChanged(forHormoneAtIndex: index) {
                    animate(at: index, theme: theme, newImage: siteImage, newTitle: cellTitle)
                } else {
                    stateImage.image = siteImage
                }
                selectionStyle = .default
                stateImage.isHidden = false
            }
        } else if index >= quantity && index <= 3 {
            animate(at: index, theme: sdk.defaults.theme.value)
        } else {
            reset()
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
