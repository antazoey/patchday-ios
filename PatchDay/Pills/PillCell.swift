//
//  PillCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillCell: TableCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateImageButton: PDBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!

    static let RowHeight: CGFloat = 170.0
    
    @discardableResult public func configure(_ params: PillCellConfigurationParameters) -> PillCell {
        loadNameLabel(params.pill)
        loadStateImage(params.pill, index: params.index)
        loadLastTakenText(params.pill)
        loadDueDateText(params.pill)
        loadTakeButton(params.pill, index: params.index)
        loadBackground(params.theme)
        setImageBadge(params.pill)
        applyTheme(params.theme)
        return self
    }
    
    /// Set the "last taken" label to the current date as a string.
    @discardableResult func stamp() -> PillCell {
        lastTakenLabel.text = PDDateFormatter.formatDate(Date())
        return self
    }
    
    @discardableResult func loadDueDateText(_ pill: Swallowable) -> PillCell {
        if let dueDate = pill.due {
            nextDueDate.text = PDDateFormatter.formatDate(dueDate)
        }
        return self
    }
    
    @discardableResult func loadLastTakenText(_ pill: Swallowable) -> PillCell {
        if let lastTaken = pill.lastTaken {
            lastTakenLabel.text = PDDateFormatter.formatDate(lastTaken)
        } else {
            lastTakenLabel.text = PDStrings.PlaceholderStrings.DotDotDot
        }
        return self
    }
    
    @discardableResult func loadStateImage(_ pill: Swallowable, index: Index) -> PillCell {
        stateImageButton.type = .pills
        stateImageButton.restorationIdentifier = "i \(index)"
        stateImageView.image = PDImages.pill
        stateImageView.tintColor = pill.isDone ? UIColor.lightGray : UIColor.blue
        return self
    }
    
    @discardableResult func loadTakeButton(_ pill: Swallowable, index: Index) -> PillCell {
        takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
        takeButton.restorationIdentifier = "t \(index)"
        takeButton.isEnabled = !pill.isDone
        if stateImageView.tintColor == UIColor.lightGray {
            takeButton.setTitle(ActionStrings.Taken)
            takeButton.isEnabled = false
            stateImageButton.isEnabled = false
        } else {
            takeButton.setTitle(ActionStrings.Take)
            takeButton.isEnabled = true
            stateImageButton.isEnabled = true
        }
        return self
    }
    
    @discardableResult func loadBackground(_ theme: AppTheme?) -> PillCell {
        imageViewView.backgroundColor = nil
        stateImageButton.backgroundColor = nil
        backgroundColor = theme?[.bg]
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.get(.Pink)
        selectedBackgroundView = backgroundView
        return self
    }
    
    // MARK: - Private
    
    @discardableResult private func loadNameLabel(_ pill: Swallowable) -> PillCell {
        nameLabel.text = pill.name
        return self
    }
    
    @discardableResult private func setImageBadge(_ pill: Swallowable) -> PillCell {
        stateImageButton.badgeValue = pill.isDue ? "!" : nil
        return self
    }
    
    @discardableResult private func applyTheme(_ theme: AppTheme?) -> PillCell {
        if let theme = theme {
            let textColor = theme[.text] ?? UIColor.black
            stateImageView.tintColor = theme[.button]
            nameLabel.textColor = textColor
            takeButton.setTitleColor(textColor)
            lastTakenLabel.textColor = textColor
            nextDueDate.textColor = textColor
            let stateImage = stateImageView.image?.withRenderingMode(.alwaysTemplate)
            stateImageView.image = stateImage
        }
        return self
    }
}
