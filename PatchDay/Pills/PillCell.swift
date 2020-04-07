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
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewContainer: UIView!

    static let RowHeight: CGFloat = 170.0
    private var styles: Styling? = nil
    
    @discardableResult public func configure(_ params: PillCellConfigurationParameters) -> PillCell {
        self.styles = params.styles
        loadNameLabel(params.pill)
        loadLastTakenText(params.pill)
        loadDueDateText(params.pill)
        loadBackground()
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
    
    @discardableResult func loadBackground() -> PillCell {
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
    
    @discardableResult private func applyTheme(at index: Index) -> PillCell {
        guard let styles = styles else { return self }
        nameLabel.textColor = styles.theme[.purple]
        arrowLabel.textColor = styles.theme[.purple]
        lastTakenLabel.textColor = styles.theme[.text]
        nextDueDate.textColor = styles.theme[.button]
        backgroundColor = styles.getCellColor(at: index)
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = styles.theme[.selected]
        return self
    }
}
