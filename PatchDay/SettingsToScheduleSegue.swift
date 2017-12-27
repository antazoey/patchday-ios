//
//  SettingsToScheduleSegue.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/23/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

internal class SettingsToScheduleSegue: UIStoryboardSegue {
    
    // Description:  SettingsToScheduleSegue animates to the left, to  either the Estrogen Schedule VC (ScheduleVC) or the Pill Schedule (PillVC).

    override internal func perform() {
        
        // Assign source and destination views as local vars
        let settingsVC = self.source.view as UIView!
        let scheduleVC = self.destination.view as UIView!
        
        // Get screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Start the schedule VC to the left
        scheduleVC!.frame = CGRect(origin: CGPoint(x: -screenWidth,y: 0), size: CGSize(width: screenWidth, height: screenHeight))
        
        // Access app's key window, insert the destination view
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow!.insertSubview(scheduleVC!,at: 0)
        
        // Animate the transisition
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            settingsVC!.frame = (settingsVC!.frame).offsetBy(dx: screenWidth, dy: 0.0)
            scheduleVC!.frame = (scheduleVC!.frame).offsetBy(dx: screenWidth, dy: 0.0)
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        }
    }
}
