//
//  ScheduleToAddPatchSegue.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/28/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PatchDetailsSegue: UIStoryboardSegue {
    
    override internal func perform() {
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
       // destination.view.alpha = 0.0
        self.destination.view.frame = CGRect(origin: CGPoint(x: 0,y: -screenHeight), size: CGSize(width: screenWidth, height: screenHeight))
        
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow!.insertSubview(self.destination.view,at: 0)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
         //   self.source.view.alpha = 0.0
            self.source.view.frame = (self.source.view.frame).offsetBy(dx: 0, dy: screenHeight)
            self.destination.view.frame = (self.destination.view.frame).offsetBy(dx: 0, dy: screenHeight)
         //   self.destination.view.alpha = 1.0

        }) { (finished) -> Void in
            self.source.view.alpha = 1.0
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        }
    }

}
