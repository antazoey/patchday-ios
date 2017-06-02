//
//  PatchDate.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/6/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

class PatchDate {
    //PatchDate object holdes date a patch was placed
    
    private var year = 0
    private var month = 0
    private var day = 0
    private var hour = 0
    private var minute = 0
    private var style = "S"
    
    // constructors
    
    init(){
        
    }
    
    init(year: Int,month: Int,day: Int, hour: Int, minute: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
    }
    
    // end constructors
    
    // getters
    
    func getYear() -> Int {
        return self.year
    }
    
    func getStyle() -> String {
        return self.style
    }
    
    // END getters
    
    // setters
    
    func setStyle(style: String) {
        self.style = style
    }
    
    // END setters
    
    // Comparable functions
    
    static func < (lhs: PatchDate, rhs: PatchDate) -> Bool {
        return lhs.getDate() < rhs.getDate()
    }
    
    static func > (lhs: PatchDate, rhs: PatchDate) -> Bool {
        return lhs.getDate() > rhs.getDate()
    }
    
    static func == (lhs: PatchDate, rhs: PatchDate) -> Bool {
        return lhs.getDate() == rhs.getDate()
    }
    
    // END Comparable functions
    
    // return methods
    
    func string() -> String{
        var patchDateString = ""
        let patchDate = createDate(year: self.year, month: self.month,
            day: self.day, hour: self.hour, minute: self.minute)
        let patchDateFormatter = DateFormatter()
        
        // Military
        if self.getStyle() == "M" {
            patchDateFormatter.dateFormat = "MMMM d"
            let timeString = PatchDate.miltaryToStandard(hour: self.hour, minute: self.minute)
            patchDateString = patchDateFormatter.string(from: patchDate!) + " at " + timeString
        }
        
        // Standard
        else if self.getStyle() == "S" {
            patchDateFormatter.dateStyle = .medium
            patchDateFormatter.timeStyle = .short
            patchDateString = patchDateFormatter.string(from: patchDate!)
        }
        return patchDateString
    }
    
    func getDate() -> Date {
        let patchDate = createDate(year: self.year, month: self.month,
            day: self.day, hour: self.hour, minute: self.minute)
        return patchDate!
    }
    
    func nextPatchDate() -> String {
        var patchDateString = ""
        let calendar = Calendar.current
        let nextDate = calendar.date(byAdding: .second, value: 302400, to: self.getDate())
        let patchDateFormatter = DateFormatter()
        
        // military
        if self.style == "M" {
            patchDateFormatter.dateFormat = "MMMM d"
            let timeString = PatchDate.miltaryToStandard(hour: self.hour, minute: self.minute)
            patchDateString = patchDateFormatter.string(from: nextDate!) +
            " at " + timeString
        }
            
        // standard
        else if self.style == "S" {
            patchDateFormatter.dateStyle = .long
            patchDateFormatter.timeStyle = .short
            patchDateString = patchDateFormatter.string(from: nextDate!)
        }
        return patchDateString
    }
    
    // end return methods
    
    // modifiers
    
    func progressToNow() {
        let newDate = Date()
        let unitFlags = Set<Calendar.Component>([.minute, .hour, .day, .month, .year])
        let newComponents = Calendar.current.dateComponents(unitFlags, from: newDate)
        self.year = newComponents.year!
        self.month = newComponents.month!
        self.day = newComponents.day!
        self.hour = newComponents.hour!
        self.minute = newComponents.minute!
    }
    
    // end modifiers
    
    // private functions
    
    private func createDate(year: Int,month: Int,day: Int, hour: Int, minute: Int) -> Date?{
        let patchCalendar = Calendar.current
        var patchDateComponents = DateComponents()
        patchDateComponents.year = year
        patchDateComponents.month = month
        patchDateComponents.day = day
        patchDateComponents.hour = hour
        patchDateComponents.minute = minute
        patchDateComponents.timeZone = TimeZone.current
        let date = patchCalendar.date(from: patchDateComponents)!
        return date
    }
    
    // MARK: Static
    
    static func miltaryToStandard(hour: Int, minute: Int) -> String {
        var tempHour: NSNumber
        var meridiem = "AM"
        if hour > 12 {
            // PM
            meridiem = "PM"
            tempHour = (hour - 12) as NSNumber
        }
        else {
            // AM
            if hour == 0 {
                tempHour = (hour + 12) as NSNumber
            }
            else{
                tempHour = hour as NSNumber
            }
        }
        let stringHour = tempHour.stringValue
        let tempMinute = minute as NSNumber
        var stringMinute = tempMinute.stringValue
        // add "0" to stringMinute if minute is a single digit
        if minute < 10 {
            stringMinute = "0" + stringMinute
        }
        return stringHour + ":" + stringMinute + " " + meridiem
    }
    
    static func getCurrentDateAsString() -> String {
        let currentDate = Date()
        return ""
    }
}
