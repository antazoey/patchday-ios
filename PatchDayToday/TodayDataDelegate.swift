//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation

protocol TodayDataDelegate {

    /// Gets the stored delivery method from the PatchDay App.
    func getDeliveryMethod() -> String?

    /// Gets the name of the displayed hormone site.
    func getNextHormoneSiteName() -> String?

    /// Gets
    func getNextHormoneExpirationDate() -> Date?
    func getNextPillName() -> String?
    func getNextPillDate() -> Date?
}
