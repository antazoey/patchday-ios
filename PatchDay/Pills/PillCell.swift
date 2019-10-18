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
    
    private let pills = app.sdk.pills
    public var index: Index = -1

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateImageButton: PDBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!
    
    public func load() {
        if let pill = pills.at(index) {
            nameLabel.text = pill.name
            loadStateImage(from: pill)
            stateImageButton.type = .pills
            loadLastTakenText(from: pill)
            loadDueDateText(from: pill)
            takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
            stateImageButton.restorationIdentifier = "i \(index)"
            takeButton.restorationIdentifier = "t \(index)"
            takeButton.isEnabled = (pill.isDone) ? false : true
            enableOrDisableTake()
            setBackground()
            setBackgroundSelected()
            setImageBadge(using: pill)
            applyTheme()
        }
    }
    
    /// Set the "last taken" label to the curent date as a string.
    public func stamp() {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
    }
    
    public func loadDueDateText(from pill: Swallowable) {
        nextDueDate.text = PDDateHelper.format(date: pill.due, useWords: true)
    }
    
    public func loadLastTakenText(from pill: Swallowable) {
        if let lastTaken = pill.lastTaken {
            lastTakenLabel.text = PDDateHelper.format(date: lastTaken as Date, useWords: true)
        } else {
            lastTakenLabel.text = PDStrings.PlaceholderStrings.dotDotDot
        }
    }
    
    public func loadStateImage(from pill: Swallowable) {
        stateImageView.image = PDImages.pill
        stateImageView.tintColor = pill.isDone ? UIColor.lightGray : UIColor.blue
    }
    
    public func enableOrDisableTake() {
        if stateImageView.tintColor == UIColor.lightGray {
            takeButton.setTitle(PDActionStrings.taken, for: .normal)
            takeButton.isEnabled = false
            stateImageButton.isEnabled = false
        } else {
            takeButton.setTitle(PDActionStrings.take, for: .normal)
            takeButton.isEnabled = true
            stateImageButton.isEnabled = true
        }
    }
    
    public func setBackground() {
        imageViewView.backgroundColor = nil
        stateImageButton.backgroundColor = nil
        backgroundColor = app.styles.theme[.bg]
    }
    
    // MARK: - Private
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.get(.Pink)
        selectedBackgroundView = backgroundView
    }
    
    private func setImageBadge(using pill: Swallowable) {
        stateImageButton.badgeValue = (pill.isDue) ? "!" : nil
    }
    
    private func applyTheme() {
        let textColor = app.styles.theme[.text]
        nameLabel.textColor = textColor
        takeButton.setTitleColor(textColor, for: .normal)
        lastTakenLabel.textColor = textColor
        nextDueDate.textColor = textColor
        let stateImage = stateImageView.image?.withRenderingMode(.alwaysTemplate)
        stateImageView.image = stateImage
        stateImageView.tintColor = app.styles.theme[.button]
    }
}
