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
    
    // END getters
    
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
        let patchDate = createDate(year: self.year, month: self.month,
            day: self.day, hour: self.hour, minute: self.minute)
        let patchDateFormatter = DateFormatter()
        patchDateFormatter.dateStyle = .medium
        patchDateFormatter.timeStyle = .short
        return patchDateFormatter.string(from: patchDate!)
    }
    
    func getDate() -> Date {
        let patchDate = createDate(year: self.year, month: self.month,
            day: self.day, hour: self.hour, minute: self.minute)
        return patchDate!
    }
    
    func nextPatchDate() -> String {
        let calendar = Calendar.current
        let nextDate = calendar.date(byAdding: .second, value: 302400, to: self.getDate())
        let patchDateFormatter = DateFormatter()
        patchDateFormatter.dateStyle = .medium
        patchDateFormatter.timeStyle = .short
        return patchDateFormatter.string(from: nextDate!)
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
}
