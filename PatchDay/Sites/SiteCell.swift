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
    
    private var sdk: PatchDataDelegate! = app.sdk

    public func configure(
        at index: Index,
        name: String,
        siteCount: Int,
        isEditing: Bool,
        sdk: PatchDataDelegate
    ) {
        self.sdk = sdk
        return configure(at: index, name: name, siteCount: siteCount, isEditing: isEditing)
    }
    
    public func configure(at index: Index, name: String, siteCount: Int, isEditing: Bool) {
        if index >= 0 && index < siteCount,
            let site = sdk.sites.at(index) {

            orderLabel.text = "\(index + 1)."
            orderLabel.textColor = app.styles.theme[.text]
            arrowLabel.textColor = app.styles.theme[.text]
            nameLabel.text = name
            nameLabel.textColor = app.styles.theme[.purple]
            nextLabel.textColor = app.styles.theme[.green]
            siteIndexImage.image = loadSiteIndexImage(for: site)?.withRenderingMode(.alwaysTemplate)
            siteIndexImage.tintColor = app.styles.theme[.text]
            nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
            backgroundColor = app.styles.theme[.bg]
            setBackgroundSelected()
        }
    }
    
    // Hides labels in the table cells for edit mode.
    public func swapVisibilityOfCellFeatures(cellIndex: Index, shouldHide: Bool) {
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        siteIndexImage.isHidden = shouldHide
        if cellIndex == sdk.sites.nextIndex {
            nextLabel.isHidden = shouldHide
        }
    }
    
    private func loadSiteIndexImage(for site: Bodily) -> UIImage? {
        if site.isOccupied {
            return PDImages.getSiteIndexIcon(spec: .One)
            return PDImages.getSiteIndexIcon()
        }
        return nil
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        return sdk.sites.nextIndex != index || isEditing
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = app.styles.theme[.selected]
        selectedBackgroundView = backgroundView
    }
}
