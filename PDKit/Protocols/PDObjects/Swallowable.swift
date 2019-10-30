//
//  Swallowable.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Swallowable: PDPbjectifiable {
    
    var id: UUID { get set }
    
    /// Use DTO to set all attributes.
    func set(attributes: PillAttributes)
    
    /// The name of the pill.
    var name: String { get set }
    
    /// The first time in a day to swallow.
    var time1: Date { get set }
    
    /// The second time in a day to swallow.
    var time2: Date { get set }
    
    /// Whether you want to be notified when due.
    var notify: Bool { get set }
    
    /// The number of times you are scheduled to swallow a day.
    var timesaday: Int { get set }
    
    /// The number of times you swallowed today.
    var timesTakenToday: Int { get set }
    
    /// When you last swallowed.
    var lastTaken: Date? { get set }
    
    /// When you should swallow next.
    var due: Date { get }
    
    /// If you are past due on swallowing.
    var isDue: Bool { get }
    
    /// If has never been swallowed.
    var isNew: Bool { get }
    
    /// If you are done swallowing today.
    var isDone: Bool { get }
    
    /// Put it in your body orally.
    func swallow()
    
    /// Configure properties that depend on a day-to-day basis, such as timesTakenToday.
    func awaken()
}
