//
//  SiteCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteCell: UITableViewCell {
    
    @IBOutlet weak var orderLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteIndexImage: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    
    private var sdk: PatchDataDelegate? = app?.sdk

    public func configure(
        at index: Index,
        name: String,
        siteCount: Int,
        isEditing: Bool,
        sdk: PatchDataDelegate
    ) {
        self.sdk = sdk
        return configure(
            at: index,
            name: name,
            siteCount: siteCount,
            isEditing: isEditing
        )
    }
    
    public func configure(at index: Index, name: String, siteCount: Int, isEditing: Bool) {
        if let site = sdk?.sites.at(index), let theme = app?.styles.theme {
            orderLabel.text = "\(index + 1)."
            orderLabel.textColor = theme[.text]
            arrowLabel.textColor = theme[.text]
            nameLabel.text = name
            nameLabel.textColor = theme[.purple]
            nextLabel.textColor = theme[.green]
            siteIndexImage.image = loadSiteIndexImage(for: site)?.withRenderingMode(.alwaysTemplate)
            siteIndexImage.tintColor = theme[.text]
            nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
            backgroundColor = theme[.bg]
            setBackgroundSelected()
        }
    }
    
    // Hides labels in the table cells for edit mode.
    public func swapVisibilityOfCellFeatures(cellIndex: Index, shouldHide: Bool) {
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        siteIndexImage.isHidden = shouldHide
        if cellIndex == sdk?.sites.nextIndex {
            nextLabel.isHidden = shouldHide
        }
    }
    
    private func loadSiteIndexImage(for site: Bodily) -> UIImage? {
        return PDImages.getSiteIndexIcon(for: site)
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        return sdk?.sites.nextIndex != index || isEditing
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = app?.styles.theme[.selected]
        selectedBackgroundView = backgroundView
    }
}
