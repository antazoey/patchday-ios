//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class TodayAppData: TodayAppDataDelegate {

    private let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")

    func getStoredDeliveryMethod() -> String? {
        let key = PDDefault.DeliveryMethod.rawValue
        return  defaults?.string(forKey: key)
    }
}
