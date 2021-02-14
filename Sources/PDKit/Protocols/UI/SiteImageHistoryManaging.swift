//
//  SiteImageHistoryManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 11/4/20.
//  
//

import Foundation

public protocol SiteImageHistorical {
    subscript(index: Index) -> SiteImageRecording { get }
}
