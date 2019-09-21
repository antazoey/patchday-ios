//
//  Swallowable.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Swallowable: PDPbjectifiable {
    func initializeAttributes(name: String)
    func initializeAttributes(attributes: PillAttributes)
    var name: String { get set }
    var id: UUID { get set }
    var time1: Date { get set }
    var time2: Date { get set }
    var notify: Bool { get set }
    var timesaday: Int { get set }
    var timesTakenToday: Int { get set }
    var lastTaken: Date? { get set }
    var due: Date { get }
    var isDue: Bool { get }
    var isNew: Bool { get }
    var isDone: Bool { get }
    func swallow()
    func awaken()
}
