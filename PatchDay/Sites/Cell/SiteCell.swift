//
//  SiteCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteCell: TableCell {

    private var props: SiteCellProperties!

    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteIndexImageView: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!

    private var viewModel: SiteCellViewModel? = nil

    @discardableResult
    func configure(props: SiteCellProperties) -> SiteCell {
        self.viewModel = SiteCellViewModel(props)
        self.props = props
        nameLabel.text = viewModel?.siteNameText ?? SiteStrings.NewSite
        loadOrderDependentViews()
        siteIndexImageView.image = PDIcons.siteIndexIcon.withRenderingMode(.alwaysTemplate)
        reflectTheme(row: props.row)
        prepareBackgroundSelectedView()
        return self
    }

    private func loadOrderDependentViews() {
        orderLabel.text = viewModel?.orderText
        reflectActionState()
    }

    public func reflectActionState() {
        guard let viewModel = viewModel else { return }
        let visibilityBools = viewModel.getVisibilityBools(cellIsInEditMode: isEditing)
        orderLabel.isHidden = !visibilityBools.showOrder
        arrowLabel.isHidden = visibilityBools.showNext
        siteIndexImageView.isHidden = visibilityBools.showNext
        nextLabel.isHidden = !visibilityBools.showNext
    }

    private func reflectTheme(row: Index) {
        orderLabel.textColor = PDColors[.Text]
        arrowLabel.textColor = PDColors[.Text]
        nameLabel.textColor = PDColors[.Purple]
        nextLabel.textColor = PDColors[.NewItem]
        siteIndexImageView.tintColor = PDColors[.Text]
        backgroundColor = PDColors.Cell[row]
    }

    private func prepareBackgroundSelectedView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors[.Selected]
        selectedBackgroundView = backgroundView
    }
}
