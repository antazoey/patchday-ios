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
    
    /// Set the "last taken" label to the curent date as a string.
    public func stamp() {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
    }
    
    public func setDueDateText(for pill: MOPill) {
        if let dueDate = pill.getDueDate() {
            nextDueDate.textColor = (pill.isExpired()) ? UIColor.red : UIColor.black
            nextDueDate.text = PDDateHelper.format(date: dueDate, useWords: true)
        }
    }
}
