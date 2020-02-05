//
//  Swallowable.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Swallowable: PDObjectified {
    
    var id: UUID { get set }

    /// The pill attributes DTO formed from this pill's attributes.
    var attributes: PillAttributes { get }

    /// The name of the pill.
    var name: String { get set }
    
    /// The first time in a day to take this pill.
    var time1: Date { get set }
    
    /// The second time in a day to take this pill.
    var time2: Date { get set }
    
    /// Whether you want to be notified when due.
    var notify: Bool { get set }
    
    /// The number of times you should take this pill a day.
    var timesaday: Int { get set }
    
    /// The number of times you took this pill today.
    var timesTakenToday: Int { get }
    
    /// The date when you last took this pill.
    var lastTaken: Date? { get set }
    
    /// The date when you should take this pill next.
    var due: Date? { get }
    
    /// Whether it is past the due date.
    var isDue: Bool { get }
    
    /// Whether you never took this pill before.
    var isNew: Bool { get }
    
    /// If you are done taking this pill today.
    var isDone: Bool { get }
    
    /// Sets this pill's attributes using the given DTO.
    func set(attributes: PillAttributes)
    
    /// Simulates taking the pill.
    func swallow()
    
    /// Configures properties that depend on a day-to-day basis, such as timesTakenToday.
    func awaken()
}
