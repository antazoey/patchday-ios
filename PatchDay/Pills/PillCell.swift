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

    @IBOutlet weak var lastTakenHeaderLabel: UILabel!
    @IBOutlet weak var lastTakenLabel: UILabel!

    @IBOutlet weak var nextHeaderLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
	@IBOutlet weak var imageViewContainer: UIView!
	@IBOutlet weak var badgeButton: PDBadgeButton!

	static let RowHeight: CGFloat = 170.0

	@discardableResult public func configure(_ params: PillCellConfigurationParameters) -> PillCell {
		loadNameLabel(params.pill)
		loadLastTakenText(params.pill)
		loadDueDateText(params.pill)
		loadBackground()
		loadBadge(params.pill)
		applyTheme(at: params.index)
		return self
	}

	/// Set the "last taken" label to the current date as a string.
	@discardableResult func stamp() -> PillCell {
		lastTakenLabel?.text = PDDateFormatter.formatDate(Date())
		return self
	}

	@discardableResult func loadDueDateText(_ pill: Swallowable) -> PillCell {
		if let dueDate = pill.due {
			nextDueDate?.text = PDDateFormatter.formatDate(dueDate)
		}
		return self
	}

	@discardableResult func loadLastTakenText(_ pill: Swallowable) -> PillCell {
		if let lastTaken = pill.lastTaken {
			lastTakenLabel.text = PDDateFormatter.formatDate(lastTaken)
		} else {
			lastTakenLabel?.text = PillStrings.NotYetTaken
		}
		return self
	}

	@discardableResult func loadBackground() -> PillCell {
		backgroundColor = UIColor.systemBackground
		let backgroundView = UIView()
		selectedBackgroundView = backgroundView
		return self
	}

	// MARK: - Private

	@discardableResult private func loadNameLabel(_ pill: Swallowable) -> PillCell {
		nameLabel?.text = pill.name
		return self
	}

	private func loadBadge(_ pill: Swallowable) {
		badgeButton?.badgeValue = pill.isDue ? "!" : nil
	}

	@discardableResult private func applyTheme(at index: Index) -> PillCell {
		nameLabel?.textColor = PDColors[.Purple]
		arrowLabel?.textColor = PDColors[.Purple]
        lastTakenHeaderLabel?.textColor = PDColors[.Text]
		lastTakenLabel?.textColor = PDColors[.Text]
        nextHeaderLabel?.textColor = PDColors[.Text]
		nextDueDate?.textColor = PDColors[.Button]
		backgroundColor = PDColors.Cell[index]
		selectedBackgroundView = UIView()
		selectedBackgroundView?.backgroundColor = PDColors[.Selected]
		return self
	}
}
