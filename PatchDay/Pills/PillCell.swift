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
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateImageButton: PDBadgeButton!

    static let RowHeight: CGFloat = 170.0
    private var styles: Styling? = nil
    
    @discardableResult public func configure(_ params: PillCellConfigurationParameters) -> PillCell {
        self.styles = params.styles
        loadNameLabel(params.pill)
        loadStateImage(params.pill, index: params.index)
        loadLastTakenText(params.pill)
        loadDueDateText(params.pill)
        loadTakeButton(params.pill, index: params.index)
        loadBackground()
        setImageBadge(params.pill)
        applyTheme(at: params.index)
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
            lastTakenLabel.text = PillStrings.NotYetTaken
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
        takeButton.restorationIdentifier = "t \(index)"
        if !pill.isDone {
            takeButton.setTitleColor(styles?.theme[.button])
            takeButton.isEnabled = true
            takeButton.setTitle(ActionStrings.Take)
            stateImageButton.isEnabled = true
        } else {
            takeButton.setTitleColor(styles?.theme[.unselected], for: .disabled)
            takeButton.isEnabled = false
            takeButton.setTitle(ActionStrings.Taken)
            stateImageButton.isEnabled = false
        }
        return self
    }
    
    @discardableResult func loadBackground() -> PillCell {
        imageViewContainer.backgroundColor = nil
        stateImageButton.backgroundColor = nil
        backgroundColor = styles?.theme[.bg]
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
    
    @discardableResult private func applyTheme(at index: Index) -> PillCell {
        guard let styles = styles else { return self }
        let textColor = styles.theme[.text] ?? UIColor.black
        stateImageView.tintColor = styles.theme[.button]
        nameLabel.textColor = textColor
        lastTakenLabel.textColor = textColor
        nextDueDate.textColor = textColor
        let stateImage = stateImageView.image?.withRenderingMode(.alwaysTemplate)
        stateImageView.image = stateImage
        backgroundColor = styles.getCellColor(at: index)
        return self
    }
}
