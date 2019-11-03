//
//  PillCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillCell: UITableViewCell {
    
    private let sdk: PatchDataDelegate = app.sdk
    private var pill: Swallowable!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateImageButton: PDBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!
    
    @discardableResult public func load(at index: Index) -> PillCell {
        if let pill = sdk.pills.at(index) {
            loadNameLabel(pill)
            loadStateImage(pill, index: index)
            loadLastTakenText(pill)
            loadDueDateText(pill)
            loadTakeButton(pill, index: index)
            loadBackground()
            setImageBadge(pill)
            applyTheme()
        }
        return self
    }
    
    /// Set the "last taken" label to the curent date as a string.
    @discardableResult func stamp() -> PillCell {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
        return self
    }
    
    @discardableResult func loadDueDateText(_ pill: Swallowable) -> PillCell {
        nextDueDate.text = PDDateHelper.format(date: pill.due, useWords: true)
        return self
    }
    
    @discardableResult func loadLastTakenText(_ pill: Swallowable) -> PillCell {
        if let lastTaken = pill.lastTaken {
            lastTakenLabel.text = PDDateHelper.format(date: lastTaken as Date, useWords: true)
        } else {
            lastTakenLabel.text = PDStrings.PlaceholderStrings.dotDotDot
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
            takeButton.setTitle(PDActionStrings.taken, for: .normal)
            takeButton.isEnabled = false
            stateImageButton.isEnabled = false
        } else {
            takeButton.setTitle(PDActionStrings.take, for: .normal)
            takeButton.isEnabled = true
            stateImageButton.isEnabled = true
        }
        return self
    }
    
    @discardableResult func loadBackground() -> PillCell {
        imageViewView.backgroundColor = nil
        stateImageButton.backgroundColor = nil
        backgroundColor = app.styles.theme[.bg]
        
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
        stateImageButton.badgeValue = (pill.isDue) ? "!" : nil
        return self
    }
    
    @discardableResult private func applyTheme() -> PillCell {
        let textColor = app.styles.theme[.text]
        nameLabel.textColor = textColor
        takeButton.setTitleColor(textColor, for: .normal)
        lastTakenLabel.textColor = textColor
        nextDueDate.textColor = textColor
        let stateImage = stateImageView.image?.withRenderingMode(.alwaysTemplate)
        stateImageView.image = stateImage
        stateImageView.tintColor = app.styles.theme[.button]
        return self
    }
}
