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
            let site = Schedule.siteSchedule.getSite(at: index) {
            orderLabel.text = "\(index + 1)."
            orderLabel.textColor = appDelegate.themeManager.text_c
            nameLabel.text = name
            estrogenScheduleImage.tintColor = UIColor.red
            nextLabel.textColor = PDColors.getColor(.Green)
            estrogenScheduleImage.image = loadEstrogenImages(for: site)
            nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
            backgroundColor = appDelegate.themeManager.bg_c
            setBackgroundSelected()
        }
    }
    
    // Hides labels in the table cells for edit mode.
    public func swapVisibilityOfCellFeatures(cellIndex: Index, shouldHide: Bool) {
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        estrogenScheduleImage.isHidden = shouldHide
        if cellIndex == Schedule.siteSchedule.nextIndex(changeIndex: Defaults.setSiteIndex) {
            nextLabel.isHidden = shouldHide
        }
    }
    
    private func loadEstrogenImages(for site: MOSite) -> UIImage? {
        if site.isOccupied() {
            return  #imageLiteral(resourceName: "ES Icon")
        } else if site.isOccupied() {
            let estro = Array(site.estrogenRelationship!)[0] as! MOEstrogen
            if let i = Schedule.estrogenSchedule.getIndex(for: estro) {
                return PDImages.getSiteIcon(at: i)
            }
        }
        return nil
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        let nextIndex = Schedule.siteSchedule.nextIndex(changeIndex: Defaults.setSiteIndex)
        return ((nextIndex != index) || isEditing)
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.getColor(.Pink)
        selectedBackgroundView = backgroundView
    }
}
