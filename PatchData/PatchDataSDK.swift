//
//  PatchDataApi.swift
//  PatchData
//
//  Created by Juliya Smith on 1/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PatchDataSDK : NSObject {
    
    public let schedule: PDSchedule
    public let defaults: PDDefaults
    public let state: PDState
    public let estrogenSchedule: EstrogenSchedule
    public let siteSchedule: SiteSchedule
    public let pillSchedule: PillSchedule
    public let pdSharedData: PDSharedData
    
    public override init() {
        schedule = PDSchedule()
        defaults = schedule.defaults
        state = schedule.state
        estrogenSchedule = schedule.estrogenSchedule
        siteSchedule = schedule.siteSchedule
        pillSchedule = schedule.pillSchedule
        pdSharedData = schedule.sharedData
        super.init()
    }
}
