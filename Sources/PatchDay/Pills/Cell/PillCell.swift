//
//  PillCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  
//

import UIKit
import PDKit

class PillCell: TableCell, PillCellProtocol {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!

    @IBOutlet weak var lastTakenHeaderLabel: UILabel!
    @IBOutlet weak var lastTakenLabel: UILabel!

    @IBOutlet weak var nextHeaderLabel: UILabel!
    @IBOutlet weak var nextDueDateLabel: UILabel!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    static let RowHeight: CGFloat = 170.0
    private var viewModel: PillCellViewModelProtocol?

    @discardableResult
    public func configure(_ params: PillCellConfigurationParameters) -> PillCellProtocol {
        self.viewModel = PillCellViewModel(pill: params.pill)
        lastTakenLabel?.text = viewModel?.lastTakenText
        nameLabel?.text = params.pill.name
        nextDueDateLabel?.text = viewModel?.dueDateText
        loadBackground()
        loadBadge(params.pill)
        applyTheme(at: params.index)
        return self
    }

    /// Set the "last taken" label to the current date as a string.
    @discardableResult func stamp() -> PillCellProtocol {
        lastTakenLabel?.text = PDDateFormatter.formatDate(Date())
        return self
    }

    func loadBackground() {
        backgroundColor = UIColor.systemBackground
        let backgroundView = UIView()
        selectedBackgroundView = backgroundView
    }

    // MARK: - Private

    private func loadBadge(_ pill: Swallowable) {
        badgeButton?.badgeValue = pill.isDue ? "!" : nil
    }

    private func applyTheme(at index: Index) {
        nameLabel?.textColor = PDColors[.Purple]
        arrowLabel?.textColor = PDColors[.Purple]
        lastTakenHeaderLabel?.textColor = PDColors[.Text]
        lastTakenLabel?.textColor = PDColors[.Text]
        nextHeaderLabel?.textColor = PDColors[.Text]
        nextDueDateLabel?.textColor = PDColors[.Button]
        backgroundColor = PDColors.Cell[index]
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = PDColors[.Selected]
    }
}
