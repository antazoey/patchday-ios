//
//  NotificationUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class NotificationsUD: PDKeyStorable {
    
    public typealias Value = Bool
    
    public typealias RawValue = Bool
    
    public var value: Bool
    
    public var rawValue: Bool { return value }
    
    public static var key = PDDefault.Notifications
    
    public required init(with val: Bool) { value = val }
}
