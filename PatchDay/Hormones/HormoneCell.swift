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
    
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    private var sdk: PatchDataSDK?
    private var styles: Styling?
    private var _siteImage: UIImage? = nil
    
    public var siteImage: UIImage? {
        _siteImage
    }

    @discardableResult
    public func configure(at row: Index, sdk: PatchDataSDK, styles: Styling) -> HormoneCell {
        self.sdk = sdk
        self.styles = styles
        backgroundColor = styles.theme[.bg]
        setSiteImage(at: row)
        return reflectHormone(at: row).applyTheme(at: row)
    }

    ///  Should be called after `configure()` and only when it is known what its animation should be.
    public func reflectSiteImage(animate: AnimationCheckResult) {
        switch animate {
        case .AnimateFromAdd: animateNewCell()
        case .AnimateFromEdit: animateEdittedCell()
        case .AnimateFromRemove: animateRemovedCell()
        case .NoAnimationNeeded: stateImageView.image = self._siteImage
        }
    }
    
    // MARK: - Private

    private func setSiteImage(at row: Index) {
        guard let sdk = sdk else { return }
        let quantity = sdk.settings.quantity.rawValue
        guard row < quantity && row >= 0 else { return }
        guard let hormone = sdk.hormones.at(row) else { return }
        let theme = sdk.settings.theme.value
        let method = sdk.settings.deliveryMethod.value
        let siteImageDeterminationParams = SiteImageDeterminationParameters(
            hormone: hormone, deliveryMethod: method, theme: theme
        )
        self._siteImage = SiteImages.get(from: siteImageDeterminationParams)
    }
    
    private func reflectHormone(at row: Index) -> HormoneCell {
        guard let sdk = sdk else { return self }
        let quantity = sdk.settings.quantity
        if let hormone = sdk.hormones.at(row), row < quantity.rawValue && row >= 0 {
            attachToModel(hormone, row)
        } else {
            reset()
        }
        return self
    }

    private func attachToModel(_ hormone: Hormonal, _ hormoneIndex: Index) {
        guard let sdk = sdk else { return }
        let method = sdk.settings.deliveryMethod.value
        loadDateLabel(for: hormone)
        loadBadge(at: hormoneIndex, isExpired: hormone.isExpired, deliveryMethod: method)
        selectionStyle = .default
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
    

    private func setDateLabel(_ title: String?) {
        self.dateLabel.textColor =  styles?.theme[.text]
        self.dateLabel.text = title
    }

    private func reset() {
        animateRemovedCell()
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func applyTheme(at index: Int) -> HormoneCell {
        guard let styles = styles else { return self }
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = styles.theme[.selected]
        backgroundColor = styles.getCellColor(at: index)
        return self
    }
    
    private func animateRemovedCell() {
        guard self.stateImageView.alpha > 0 else { return }
        UIView.animate(withDuration: 0.75) {
            self.stateImageView.alpha = 0
        }
    }
    
    private func animateNewCell() {
        stateImageView.isHidden = true
        stateImageView.alpha = 0
        UIView.animate(withDuration: 0.75) {
            self.stateImageView.alpha = 1
            self.stateImageView.isHidden = false
            self.stateImageView.image = self._siteImage
        }
    }
    
    private func animateEdittedCell() {
        stateImageView.alpha = 1
        UIView.transition(
            with: stateImageView as UIView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.stateImageView.image = self._siteImage },
            completion: nil
        )
    }
}
