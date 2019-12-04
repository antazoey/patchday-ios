//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation

protocol TodayAppDataDelegate {
    func getDeliveryMethod() -> String?
    func getSiteName() -> String?
    func getHormoneDate() -> Date?
    func getNextPillName() -> String?
    func getNextPillDate() -> Date?
}
