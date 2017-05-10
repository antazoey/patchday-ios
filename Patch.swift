//
//  Patch.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

class Patch {
    
    private var location = ""
    private var patchDate = PatchDate()
    
    init(){}
    
    init(year: Int, month: Int, day: Int, hour: Int,
         minute: Int, location: String) {
        self.patchDate = PatchDate(year: year, month: month, day: day,
            hour: hour, minute: minute)
        self.location = location
    }
    
    // setters
    
    func setLocation(location: String) {
        self.location = location
    }
    
    // end setters
    
    // getters
    
    func getLocation() -> String{
        return location
    }
    
    func getPatchDate() -> PatchDate {
        return patchDate
    }
    
    // end getters
    
    // Comparable functions
    
    static func < (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.getPatchDate() < rhs.getPatchDate()
    }
    
    static func > (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.getPatchDate() > rhs.getPatchDate()
    }
    
    static func == (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.getPatchDate() == rhs.getPatchDate()
    }
    
    // END Comparable functions
    
    // String
    
    func string() -> String {
        let patchDateFormatter = DateFormatter()
        patchDateFormatter.dateStyle = .short
        patchDateFormatter.timeStyle = .short
        return patchDateFormatter.string(from: self.getPatchDate().getDate()) + "," +
            self.location
    }
    
    // END String
    
    // static functions
    
    static func stringToPatch(patchDataString: String) -> Patch {
        // String should look like "5/3/17, 10:45 AM,Right Stomach"
        
        // grab the date
        var patchDataStringArray = patchDataString.components(separatedBy: ", ")
        let patchDateString = patchDataStringArray[0]
        
        // grab time
        let newPatchDataString = patchDataStringArray[1]
        patchDataStringArray = newPatchDataString.components(separatedBy: ",")
        let patchTime = patchDataStringArray[0]
        /* Location */let patchLocation = patchDataStringArray[1]
        
        patchDataStringArray = patchDateString.components(separatedBy: "/")
        /* Day */
        let patchDay = Int(patchDataStringArray[1])
        /* Month */
        let patchMonth = Int(patchDataStringArray[0])
        /* Year */
        let patchYear  = Int(patchDataStringArray[2])! + 2000
        
        
        patchDataStringArray = patchTime.components(separatedBy: " ")
        let patchTimeNumber = patchDataStringArray[0]
        let patchPMorAM = patchDataStringArray[1]
        patchDataStringArray = patchTimeNumber.components(separatedBy: ":")
        /* Hour - AM */
        var patchHour = Int(patchDataStringArray[0])
        if patchPMorAM == "PM"{
            /* Hour - PM */
            patchHour = Int(patchDataStringArray[0])! + 12
        }
        /* Minute */
        let patchMinute = Int(patchDataStringArray[1])
        
        return Patch(year: patchYear, month: patchMonth!, day: patchDay!, hour: patchHour!, minute: patchMinute!, location: patchLocation)
    }
}
