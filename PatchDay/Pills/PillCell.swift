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
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateImageButton: MFBadgeButton!
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
            lastTakenLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
    }
    
    public func loadStateImage(from pill: Swallowable) {
        stateImage.image = PDImages.pill
        stateImage.tintColor = pill.isDone ? UIColor.lightGray : UIColor.blue
    }
    
    public func enableOrDisableTake() {
        if stateImage.tintColor == UIColor.lightGray {
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
        backgroundColor = app.theme.getCellColor(at: index)
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
        nameLabel.textColor = app.theme.textColor
        takeButton.setTitleColor(app.theme.buttonColor, for: .normal)
        lastTakenLabel.textColor = app.theme.textColor
        nextDueDate.textColor = app.theme.textColor
        let img = stateImage.image?.withRenderingMode(.alwaysTemplate)
        stateImage.image = img
        stateImage.tintColor = app.theme.buttonColor
    }
}
