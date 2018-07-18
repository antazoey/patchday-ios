//
//  PillTableViewCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateImageButton: MFBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!
    
    /// Set the "last taken" label to the curent date as a string.
    public func stamp() {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
    }
    
    public func loadDueDateText(from pill: MOPill) {
        if let dueDate = pill.getDueDate() {
            nextDueDate.text = PDDateHelper.format(date: dueDate, useWords: true)
        }
    }
    
    public func loadLastTakenText(from pill: MOPill) {
        if let lastTaken = pill.getLastTaken() {
            lastTakenLabel.text = PDDateHelper.format(date: lastTaken as Date, useWords: true)
        }
        else {
            lastTakenLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
    }
    
    public func loadStateImage(from pill: MOPill) {
        stateImage.image = PDImages.pill.withRenderingMode(.alwaysTemplate)
        if pill.isDone() {
            stateImage.tintColor = UIColor.lightGray
        }
        else {
            stateImage.tintColor = UIColor.blue
        }
    }
}
