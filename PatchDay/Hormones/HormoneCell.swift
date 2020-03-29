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
    
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    private var sdk: PatchDataSDK?
    private var styles: Styling?

    @discardableResult
    public func configure(at row: Index, sdk: PatchDataSDK, styles: Styling) -> HormoneCell {
        self.sdk = sdk
        self.styles = styles
        backgroundColor = styles.theme[.bg]
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
        case .Empty: self.stateImageView.alpha = 0; self.stateImageView.image = nil
        case .None: stateImageView.image = history.current; self.stateImageView.alpha = 1
        }
    }
    
    // MARK: - Private
    
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
    
    private func animateRemove(completion: (() ->())?=nil) {
        self.stateImageView.alpha = 1
        UIView.animate(
            withDuration: 0.75,
            animations: { self.stateImageView.alpha = 0 }) {
                isReady in
                print("IsREAD \(isReady)")
                if isReady {
                    self.stateImageView.image = nil
                    self.reset()
                    completion?()
                }
        }
    }
    
    private func animateAdd(_ placeholderImage: UIImage?, completion: (() -> ())?=nil) {
        stateImageView.alpha = 0
        stateImageView.image = placeholderImage
        UIView.animate(
            withDuration: 0.75,
            animations: { self.stateImageView.alpha = 1 }) {
                void in
                completion?()
        }
    }
    
    private func animateSetSiteImage(_ image: UIImage?) {
        UIView.transition(
            with: stateImageView as UIView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.stateImageView.image = image },
            completion: nil
        )
    }
    
    private func logSetSiteImageOutcome(row: Index, mutation: HormoneMutation) {
        let log = PDLog<HormoneCell>()
        let image = self.stateImageView.image?.accessibilityIdentifier ?? "nil"
        let alpha = self.stateImageView.alpha
        log.info(
            "Logging animation outcome for row \(row) with mutation factory: \(mutation). Image: \(image). Alpha: \(alpha)"
        )
    }
}
