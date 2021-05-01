//
//  PillCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.

import UIKit
import PDKit

class PillCell: TableCell, PillCellProtocol {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var timesTakenTodayLabel: UILabel!
    @IBOutlet weak var lastTakenHeaderLabel: UILabel!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextHeaderLabel: UILabel!
    @IBOutlet weak var nextDueDateLabel: UILabel!
    @IBOutlet weak var badgeButton: PDBadgeButton!

    static let RowHeight: CGFloat = 170.0
    private var viewModel: PillCellViewModelProtocol?

    @discardableResult
    public func configure(_ params: PillCellConfigurationParameters) -> PillCellProtocol {
        let viewModel = PillCellViewModel(pill: params.pill)
        self.viewModel = viewModel
        timesTakenTodayLabel?.text = viewModel.timesQuotientText
        lastTakenLabel?.text = viewModel.lastTakenText

        // TODO: Remove
        if params.index == 0 {
            tprint("TEST")
            tprint(lastTakenLabel?.text)
        }

        nameLabel?.text = params.pill.name
        nextDueDateLabel?.text = viewModel.dueDateText
        loadBackground()
        loadBadge(params.pill)
        applyTheme(at: params.index)
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
        backgroundColor = PDColors.Cell[index]
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = PDColors[.Selected]
    }
}
