//
//  NotificationsMinutesBefore.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class NotificationsMinutesBeforeUD: PDKeyStorable {
    
    public typealias Value = Int
    
    public typealias RawValue = Int
    
    public required init(with val: Int) { value = val }
    
    public convenience required init() { self.init(with: 0) }
    
    public var value: Int
    
    public var rawValue: Int { return value }
    
    public static var key = PDDefault.NotiicationsMinutesBefore
}
