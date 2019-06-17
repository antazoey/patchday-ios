//
//  SiteCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SiteCell: UITableViewCell {
    
    @IBOutlet weak var orderLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var estrogenScheduleImage: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    
    public func configure(at index: Index, name: String, siteCount: Int, isEditing: Bool) {
        if index >= 0 && index < siteCount,
            let site = patchData.siteSchedule.getSite(at: index) {
            orderLabel.text = "\(index + 1)."
            orderLabel.textColor = app.theme.textColor
            arrowLabel.textColor = app.theme.textColor
            nameLabel.text = name
            nameLabel.textColor = app.theme.purpleColor
            nextLabel.textColor = app.theme.greenColor
            estrogenScheduleImage.image = loadEstrogenImages(for: site)?.withRenderingMode(.alwaysTemplate)
            estrogenScheduleImage.tintColor = app.theme.textColor
            nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
            backgroundColor = app.theme.bgColor
            setBackgroundSelected()
        }
    }
    
    // Hides labels in the table cells for edit mode.
    public func swapVisibilityOfCellFeatures(cellIndex: Index, shouldHide: Bool) {
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        estrogenScheduleImage.isHidden = shouldHide
        if cellIndex == patchData.siteSchedule.nextIndex(changeIndex: patchData.defaults.setSiteIndex) {
            nextLabel.isHidden = shouldHide
        }
    }
    
    private func loadEstrogenImages(for site: MOSite) -> UIImage? {
        if site.isOccupied() {
            return  #imageLiteral(resourceName: "ES Icon")
        }
        return nil
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        let nextIndex = patchData.siteSchedule.nextIndex(changeIndex: patchData.defaults.setSiteIndex)
        return ((nextIndex != index) || isEditing)
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = app.theme.selectedColor
        selectedBackgroundView = backgroundView
    }
}
