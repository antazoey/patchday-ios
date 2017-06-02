//
//  SettingsToScheduleSegue.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/23/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsToScheduleSegue: UIStoryboardSegue {

    override func perform() {
        // Assign source and destination views as local vars
        let settingsVCView = self.source.view as UIView!
        let patchScheduleVCView = self.destination.view as UIView!
        
        // Get screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Start the schedule VC to the left
        patchScheduleVCView!.frame = CGRect(origin: CGPoint(x: -screenWidth,y: 0), size: CGSize(width: screenWidth, height: screenHeight))
        
        // Access app's key window, insert the destination view
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow!.insertSubview(patchScheduleVCView!,at: 0)
        
        // Animate the transisition
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            settingsVCView!.frame = (settingsVCView!.frame).offsetBy(dx: screenWidth, dy: 0.0)
            patchScheduleVCView!.frame = (patchScheduleVCView!.frame).offsetBy(dx: screenWidth, dy: 0.0)
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        }
    }
}
