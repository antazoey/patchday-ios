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
        applyTheme(at: row)
        guard let sdk = viewModel.sdk else { return self }
        let quantity = sdk.settings.quantity
        if row < quantity.rawValue && row >= 0 {
            attachToModel(sdk, hormone, row)
        } else {
            reset()
        }
        return self
    }

    private func attachToModel(_ sdk: PatchDataSDK, _ hormone: Hormonal, _ hormoneIndex: Index) {
        let method = sdk.settings.deliveryMethod.value
        loadDateLabel(for: hormone)
        loadBadge(at: hormoneIndex, isExpired: hormone.isExpired, deliveryMethod: method)
        loadSiteViews(sdk, hormone, hormoneIndex)
        selectionStyle = .default
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

    private func applyTheme(at index: Int) {
        guard let styles = styles else { return }
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = styles.theme[.selected]
        backgroundColor = styles.getCellColor(at: index)
    }

    private func loadDateLabel(for hormone: Hormonal) {
        dateLabel.textColor = hormone.isExpired ? UIColor.red : UIColor.black
        let size: CGFloat = AppDelegate.isPad ? 38.0 : 15.0
        dateLabel.font = UIFont.systemFont(ofSize: size)
        if !hormone.date.isDefault() {
            setDateLabel(PDDateFormatter.formatDate(hormone.date))
        }
    }

    private func loadBadge(at index: Int, isExpired: Bool, deliveryMethod: DeliveryMethod) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.type = deliveryMethod == DeliveryMethod.Injections
            ? PDBadgeButtonType.injections : PDBadgeButtonType.patches
        badgeButton.badgeValue = isExpired ? "!" : nil
    }

    private func loadSiteViews(_ sdk: PatchDataSDK, _ hormone: Hormonal, _ hormoneIndex: Index) {
        let theme = sdk.settings.theme.value
        let method = sdk.settings.deliveryMethod.value
        let siteImageDeterminationParams = SiteImageDeterminationParameters(
            hormone: hormone, deliveryMethod: method, theme: theme
        )
        let siteImage = PDImages.getSiteImage(from: siteImageDeterminationParams)
        let animationCheckResult = checkHormoneForStateChanges(hormone, siteImage, hormoneIndex)
        setSiteImage(
            at: hormoneIndex,
            animationCheckResult: animationCheckResult,
            newImage: siteImage
        )
    }
    
    private func checkHormoneForStateChanges(
        _ hormone: Hormonal, _ image: UIImage, _ hormoneIndex: Index
    ) -> AnimationCheckResult {
        guard let criteria = HormonesViewModel.animationCriteria else { return .NoAnimationNeeded }
        return criteria.shouldAnimate(hormone: hormone, siteId: hormone.siteId, index: hormoneIndex)
    }

    private func setSiteImage(
        at index: Index, animationCheckResult: AnimationCheckResult, newImage: UIImage?=nil
    ) {
        guard let newImage = newImage else {
            animateRemovedCell()
            return
        }
        switch animationCheckResult {
        case .AnimateFromAdd: animateNewCell(newImage)
        case .AnimateFromEdit: animateEdittedCell(newImage)
        case .AnimateFromRemove: animateRemovedCell()
        case .NoAnimationNeeded: self.stateImage.image = newImage
        }
    }
    
    private func animateRemovedCell() {
        UIView.animate(withDuration: 0.75) {
            self.stateImage.alpha = 0
            self.stateImage.image = nil
        }
    }
    
    private func animateNewCell(_ image: UIImage) {
        self.stateImage.isHidden = true
        self.stateImage.alpha = 0
        UIView.animate(withDuration: 0.75) {
            self.stateImage.alpha = 1
            self.stateImage.isHidden = false
            self.stateImage.image = image
        }
    }
    
    private func animateEdittedCell(_ image: UIImage) {
        UIView.transition(
            with: stateImage as UIView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.stateImage.image = image },
            completion: nil
        )
    }
}
