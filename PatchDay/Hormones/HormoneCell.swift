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
		} else {
			reset()
		}
		return self
	}

	private func attachToModel(_ hormone: Hormonal, _ hormoneIndex: Index) {
		loadDateLabel(for: hormone)
		loadBadge(hormone, at: hormoneIndex)
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

    private func loadBadge(_ hormone: Hormonal, at index: Int) {
		badgeButton.restorationIdentifier = String(index)
        badgeButton.type = hormone.deliveryMethod == .Injections ? .injections : .patches
        let shouldShow = hormone.isPastNotificationTime
		badgeButton.badgeValue = shouldShow ? "!" : nil
	}


	private func setDateLabel(_ title: String?) {
		self.dateLabel.textColor = PDColors[.Text]
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
		selectedBackgroundView = UIView()
		selectedBackgroundView?.backgroundColor = PDColors[.Selected]
		backgroundColor = PDColors.Cell[index]
		return self
	}

	private func animateRemove(completion: (() -> ())? = nil) {
		self.siteImageView.alpha = 1
		UIView.animate(
			withDuration: 0.75,
			animations: { self.siteImageView.alpha = 0 }) {
			isReady in
			print("IsREAD \(isReady)")
			if isReady {
				self.siteImageView.image = nil
				self.reset()
				completion?()
			}
		}
	}

	private func animateAdd(_ placeholderImage: UIImage?, completion: (() -> ())? = nil) {
		siteImageView.alpha = 0
		siteImageView.image = placeholderImage
		UIView.animate(
			withDuration: 0.75,
			animations: { self.siteImageView.alpha = 1 }) {
			void in
			completion?()
		}
	}

	private func animateSetSiteImage(_ image: UIImage?) {
		UIView.transition(
			with: siteImageView as UIView,
			duration: 0.75,
			options: .transitionCrossDissolve,
			animations: { self.siteImageView.image = image },
			completion: nil
		)
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
