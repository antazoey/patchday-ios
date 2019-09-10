//
//  PDDateSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 9/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDDataSharing {
    func setEstrogenDataForToday(latestExpiredEstrogen: Hormonal,
                                 nextSuggestedSite: SiteName,
                                 interval: ExpirationIntervalUD,
                                 deliveryMethod: DeliveryMethodUD,
                                 index: Index,
                                 setSiteIndex: @escaping (Int) -> ())
    func setPillDataForToday(nextPill: Swallowable)
}
