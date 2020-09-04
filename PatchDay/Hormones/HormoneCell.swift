//
//  HormoneCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

enum SiteImageReflectionError: Error {
    case AddWithoutGivenPlaceholderImage
}

class HormoneCell: TableCell {

    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!
    @IBOutlet weak var overnightImage: UIImageView!

    private var sdk: PatchDataSDK?

    @discardableResult
    public func configure(at row: Index, _ sdk: PatchDataSDK) -> HormoneCell {
        self.sdk = sdk
        backgroundColor = UIColor.systemBackground
        return reflectHormone(at: row).applyTheme(at: row)
    }

    ///  Should be called after `configure()` and only when it is known what its animation should be.
    public func reflectSiteImage(_ history: SiteImageHistory) throws {
        let mutation = history.differentiate()
        switch mutation {
            case .Add:
                guard let image = history.current else {
                    throw SiteImageReflectionError.AddWithoutGivenPlaceholderImage
                }
                animateAdd(image)
            case .Edit: animateSetSiteImage(history.current)
            case .Remove: animateRemove()
            case .Empty: siteImageView.alpha = 0; siteImageView.image = nil
            case .None: siteImageView.image = history.current; siteImageView.alpha = 1
        }
    }

    // MARK: - Private

    private func reflectHormone(at row: Index) -> HormoneCell {
        guard let sdk = sdk else { return self }
        let quantity = sdk.settings.quantity
        if let hormone = sdk.hormones[row], row < quantity.rawValue && row >= 0 {
            attachToModel(hormone, row)
            // Don't put moon on if already expired
            if hormone.expiresOvernight && !hormone.isExpired {
                overnightImage.image = PDIcons.moonIcon
            } else {
                overnightImage.image = nil
            }
        } else {
            reset()
        }
        return self
    }

    private func attachToModel(_ hormone: Hormonal, _ hormoneIndex: Index) {
        loadDateLabel(for: hormone, hormoneIndex)
        loadBadge(hormone, at: hormoneIndex)
        selectionStyle = .default
    }

    private func loadDateLabel(for hormone: Hormonal, _ index: Index) {
        dateLabel.textColor = hormone.isExpired ? UIColor.red : PDColors[.Text]
        let size: CGFloat = AppDelegate.isPad ? 38.0 : 15.0
        dateLabel.font = UIFont.systemFont(ofSize: size)
        if !hormone.date.isDefault(), let expiration = hormone.expiration {
            let prefix = HormoneStrings.create(hormone).expirationText
            let dateString = PDDateFormatter.formatDay(expiration)
            setDateLabel("\(prefix) \(dateString)", hormone)
        }
        dateLabel.setNeedsDisplay()
    }

    private func loadBadge(_ hormone: Hormonal, at index: Int) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.type = hormone.deliveryMethod == .Injections
            ? .forInjectionsHormonesView : .forPatchesHormonesView
        let shouldShow = hormone.isPastNotificationTime
        badgeButton.badgeValue = shouldShow ? "!" : nil
        badgeButton.setNeedsDisplay()
    }

    private func setDateLabel(_ title: String?, _ hormone: Hormonal) {
        dateLabel.textColor = hormone.isPastNotificationTime ? UIColor.red : PDColors[.Text]
        dateLabel.text = title
        dateLabel.setNeedsDisplay()
    }

    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func applyTheme(at index: Int) -> HormoneCell {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = PDColors[.Selected]
        backgroundColor = PDColors.Cell[index]
        overnightImage.image = overnightImage.image?.withTintColor(PDColors[.Text])
        return self
    }

    private func animateRemove(completion: (() -> Void)? = nil) {
        self.siteImageView.alpha = 1
        UIView.animate(
            withDuration: 0.75,
            animations: { self.siteImageView.alpha = 0 }) {
            isReady in
            if isReady {
                self.siteImageView.image = nil
                self.reset()
                completion?()
            }
        }
    }

    private func animateAdd(_ placeholderImage: UIImage?, completion: (() -> Void)? = nil) {
        siteImageView.alpha = 0
        siteImageView.image = placeholderImage
        UIView.animate(
            withDuration: 0.75,
            animations: { self.siteImageView.alpha = 1 }) {
            _ in
            completion?()
        }
    }

    private func animateSetSiteImage(_ image: UIImage?) {
        guard siteImageView.image != image else { return }
        DispatchQueue.main.async {
            UIView.transition(
                with: self.siteImageView as UIView,
                duration: 0.75,
                options: .transitionCrossDissolve,
                animations: { self.siteImageView.image = image },
                completion: nil
            )
        }
    }

    private func logSetSiteImageOutcome(row: Index, mutation: HormoneMutation) {
        let log = PDLog<HormoneCell>()
        let image = siteImageView.image?.accessibilityIdentifier ?? "nil"
        let alpha = siteImageView.alpha
        log.info(
            "Logging animation outcome for row \(row) with mutation factory: \(mutation). Image: \(image). Alpha: \(alpha)"
        )
    }
}
