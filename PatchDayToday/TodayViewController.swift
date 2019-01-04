//
//  TodayViewController.swift
//  patchdayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import UIKit
import NotificationCenter
import PDKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nextEstrogenLabel: UILabel!
    
    @IBOutlet weak var estrogenSiteLabel: UILabel!
    @IBOutlet weak var estrogenDateLabel: UILabel!
    
    @IBOutlet weak var nextPillNameLabel: UILabel!
    @IBOutlet weak var nextPillTakeDateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nextEstro = PDPDSharedDataController.getNextEstrogen()
        let nextPill = PDPDSharedDataController.getNextPill()
        
        nextEstrogenLabel.text = PDPDSharedDataController.usingPatches() ? NSLocalizedString("Change:", comment: "Short label on Today App") : NSLocalizedString("Inject:", comment: "Short label on Today App")
        if let n = nextEstro.siteName {
            estrogenSiteLabel.text = n
        } else {
            estrogenSiteLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let d = nextEstro.date {
            estrogenDateLabel.text = PDDateHelper.format(date: d, useWords: true)
        } else {
            estrogenDateLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let n = nextPill.name {
            nextPillNameLabel.text = n
        } else {
            nextPillNameLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let d = nextPill.nextTakeDate {
            nextPillTakeDateLabel.text = PDDateHelper.format(date: d, useWords: true)
        } else {
            nextPillTakeDateLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        
    }
    
    @IBAction func widgetTapped(_ sender: Any) {
        
        let myAppUrl = NSURL(string: "PatchDay://")!
        extensionContext?.open(myAppUrl as URL, completionHandler: { (success) in
            if (!success) {
                print("Failure to open PatchDay")
            }
        })
    }
    
/*
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
    }
*/
    
}
