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

    private var props: SiteCellProperties?
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteIndexImage: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!

    @discardableResult func configure(props: SiteCellProperties) -> SiteCell {
        self.props = props
        orderLabel.text = "\(props.rowIndex + 1)."
        nextLabel.isHidden = nextTitleShouldHide(at: props.rowIndex, isEditing: isEditing)
        loadSiteProperties()
        reflectTheme()
        prepareBackgroundSelectedView()
        reflectActionState(cellIndex: props.rowIndex, actionState: .Reading)
        return self
    }

    public func reflectActionState(cellIndex: Index, actionState: SiteTableActionState) {
        let shouldHide = actionState == .Editing
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        siteIndexImage.isHidden = shouldHide
        if cellIndex == props?.nextSiteIndex {
            nextLabel.isHidden = shouldHide
        }
    }

    private func loadSiteProperties() {
        if let site = props?.site {
            nameLabel.text = site.name
            siteIndexImage.image = loadSiteIndexImage(for: site)?.withRenderingMode(.alwaysTemplate)
        }
    }

    private func reflectTheme() {
        if let theme = props?.theme {
            orderLabel.textColor = theme[.text]
            arrowLabel.textColor = theme[.text]
            nameLabel.textColor = theme[.purple]
            nextLabel.textColor = theme[.green]
            siteIndexImage.tintColor = theme[.text]
            backgroundColor = theme[.bg]
        }
    }

    private func loadSiteIndexImage(for site: Bodily) -> UIImage? {
        PDImages.getSiteIndexIcon(for: site)
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        if let rowIndex = props?.rowIndex {
            return rowIndex != index || isEditing
        }
        return isEditing
    }
    
    private func prepareBackgroundSelectedView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = app?.styles.theme[.selected]
        selectedBackgroundView = backgroundView
    }
}
