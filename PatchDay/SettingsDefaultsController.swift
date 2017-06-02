//
//  SettingsDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

enum defaultKeys: String {
    case interval = "patchChangeInterval"
    case pcount = "numberOfPatches"
    case autoChoose = "autoChooseLocation"
}

class SettingsDefaultsController: NSObject {
    
    static private var patchInterval: String = "Half-Week"
    static private var numberOfPatches: String =  "4"
    static private var autoChooseLocation: Bool = false
    
   static private var defaults = UserDefaults.standard

    // helper
    
    static func setFromDefaults() {
        let interval = defaults.object(forKey: defaultKeys.interval.rawValue)
        let patchCount = defaults.object(forKey: defaultKeys.pcount.rawValue)
        let autoChoose = defaults.object(forKey: defaultKeys.autoChoose.rawValue)
        // set members
        if interval != nil {
            self.patchInterval = interval as! String
        }
        if patchCount != nil {
            self.numberOfPatches = patchCount as! String
        }
        if autoChoose != nil {
            self.autoChooseLocation = autoChoose as! Bool
        }
        
    }
    
    // Getters
    
    static func getPatchInterval() -> String {
        return self.patchInterval
    }
    
    static func getNumberOfPatches() -> String {
        return self.numberOfPatches
    }
    
    static func getAutoChooseLocation() -> Bool {
        return self.autoChooseLocation
    }
    
    // Setters
    
    static func setPatchInterval(to: String) {
        self.patchInterval = to
        self.defaults.set(self.getPatchInterval(), forKey: defaultKeys.interval.rawValue)
        self.synchonize()
    }
    
    static func setNumberOfPatches(to: String) {
        self.numberOfPatches = to
        defaults.set(self.getNumberOfPatches(), forKey: defaultKeys.pcount.rawValue)
        self.synchonize()
    }
    
    static func setAutoChooseLocation(to: Bool) {
        self.autoChooseLocation = to
        self.defaults.set(self.autoChooseLocation, forKey: defaultKeys.autoChoose.rawValue)
        self.synchonize()
    }
    
    static func synchonize() {
        defaults.synchronize()
        self.setFromDefaults()
    }
    
    
    

}
