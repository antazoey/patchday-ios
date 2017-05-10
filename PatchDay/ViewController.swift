//
//  ViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController {
    
    //MARK:  Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var patchSchedule = PatchSchedule()
    
    func readPatchSchedule() {
        var newPatch1 = Patch()
        var newPatch2 = Patch()
        var newPatch3 = Patch()
        var newPatch4 = Patch()
        let tempSchedule = PatchScheduleMO(context: context)
        newPatch1 = Patch.stringToPatch(patchDataString: (tempSchedule.patch_a!))
        newPatch2 = Patch.stringToPatch(patchDataString: (tempSchedule.patch_b!))
        newPatch3 = Patch.stringToPatch(patchDataString: (tempSchedule.patch_c!))
        newPatch4 = Patch.stringToPatch(patchDataString: (tempSchedule.patch_d!))
        self.patchSchedule = PatchSchedule(patches: newPatch1, newPatch2, newPatch3, newPatch4)
        // if any of the patches are standard, they are unchanged by the user and are removed
        for patch in self.patchSchedule.patches {
            // standard is assessed by an impossible year
            if patch.getPatchDate().getYear() < 2017 {
                self.patchSchedule.remove(patchToRemove: patch)
            }
        }
    }
    
    // END TEMPORARY FOR TESTING
    
    //MARK: References
    
    @IBOutlet weak var text_display:UITextView!
    
    @IBOutlet weak var yes_button: UIButton!
    
    //MARK:  Action Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func viewScheduleTapped(_ sender: Any) {
        self.readPatchSchedule()
        text_display.text = patchSchedule.string()
        yes_button.isEnabled = false
    }
    
    @IBAction func changePatchTapped(_ sender: Any) {
        text_display.text = patchSchedule.nextPatchWhenAndWhere()
        + "\n\n Have you changed it?"
        yes_button.isEnabled = true
        
    }
    @IBAction func yesTapped(_ sender: Any) {
        // Schedule updates
        patchSchedule.changePatch()
        let schedule = PatchScheduleMO(context: context)
        var patches = [schedule.patch_a, schedule.patch_b, schedule.patch_c, schedule.patch_d]
        for i in 0...patchSchedule.length()-1 {
            patches[i] = patchSchedule.getPatch(rank: i).string()
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let _ = navigationController?.popViewController(animated: true)
        
        // UI Changes
        text_display.text = "Patch Changed!" + "\n\n" + patchSchedule.string()
        yes_button.isEnabled = false
    }
    
    //MARK:  Default
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

