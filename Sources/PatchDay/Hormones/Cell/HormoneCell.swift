//
//  HormoneCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class HormoneCell: TableCell, HormoneCellProtocol {

    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!
    @IBOutlet weak var overnightImageView: UIImageView!

    private var viewModel: HormoneCellViewModelProtocol?

    @discardableResult
    public func configure(_ viewModel: HormoneCellViewModelProtocol) -> HormoneCellProtocol {
        self.viewModel = viewModel
        backgroundColor = UIColor.systemBackground
        return reflectHormone(at: viewModel.cellIndex).applyTheme()
    }

    ///  Should be called after `configure()` and only when it is known what its animation should be.
    public func reflectSiteImage(_ history: SiteImageRecording) throws {
        let mutation = history.differentiate()
        switch mutation {
            case .Add:
                guard let image = history.current else {
                    throw SiteImageReflectionError.AddWithoutGivenPlaceholderImage
                }
                animateAdd(image)
            case .Edit: animateSetSiteImage(history.current)
            case .Remove: animateRemove()
            case .Empty:
                siteImageView.alpha = 0
                siteImageView.image = nil
            case .None:
                siteImageView.image = history.current
                siteImageView.alpha = 1
        }
    }

    // MARK: - Private

    private func reflectHormone(at row: Index) -> HormoneCell {
        guard let viewModel = viewModel else { return self }
        if viewModel.showHormone {
            attachToModel()
            overnightImageView.image = viewModel.moonIcon
        } else {
            reset()
        }
        return self
    }

    private func attachToModel() {
        loadDateLabel()
        loadBadge()
        selectionStyle = .default
    }

    private func loadDateLabel() {
        guard let viewModel = viewModel else { return }
        dateLabel.font = viewModel.dateFont
        dateLabel.textColor = viewModel.dateLabelColor
        dateLabel.text = viewModel.dateString
        dateLabel.setNeedsDisplay()
        dateLabel.isHidden = false
    }

    private func loadBadge() {
        guard let viewModel = viewModel else { return }
        badgeButton.restorationIdentifier = viewModel.badgeId
        badgeButton.type = viewModel.badgeType
        badgeButton.badgeValue = viewModel.badgeValue
        badgeButton.setNeedsDisplay()
    }

    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func applyTheme() -> HormoneCell {
        guard let viewModel = viewModel else { return self }
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = PDColors[.Selected]
        backgroundColor = viewModel.backgroundColor
        overnightImageView.image = overnightImageView.image?.withTintColor(PDColors[.Text])
        return self
    }

    private func animateRemove(completion: (() -> Void)? = nil) {
        self.siteImageView.alpha = 1
        UIView.animate(
            withDuration: 0.75,
            animations: { self.siteImageView.alpha = 0 },
            completion: {
                isReady in
                if isReady {
                    self.siteImageView.image = nil
                    self.reset()
                    completion?()
                }
            }
        )
    }

    private func animateAdd(_ placeholderImage: UIImage?, completion: (() -> Void)? = nil) {
        siteImageView.alpha = 0
        siteImageView.image = placeholderImage
        UIView.animate(
            withDuration: 0.75,
            animations: { self.siteImageView.alpha = 1 },
            completion: { _ in completion?() }
        )
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
}
