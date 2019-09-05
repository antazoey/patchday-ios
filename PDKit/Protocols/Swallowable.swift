//
//  Swallowable.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Swallowable {
    var name: String { get set }
    var id: UUID { get set }
    var time1: NSDate { get set }
    var time2: NSDate { get set }
    var notify: Bool { get set }
    var timesaday: Int16 { get set }
    var lastTaken: NSDate? { get set }
    var due: Date? { get }
    var isDue: Bool { get }
    var isNew: Bool { get }
    var isDone: Bool { get }
    func swallow()
    func awaken()
    func reset()
}
