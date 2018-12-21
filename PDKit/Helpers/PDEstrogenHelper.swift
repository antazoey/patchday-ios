//
//  PDEstrogenHelper.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/10/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public typealias Index = Int

public class PDEstrogenHelper: NSObject {
    
    override public var description: String {
        return "Class for doing calculations on Dates."
    }
    
    /// Returns MOEstrogen matching id.
    public static func getEstrogen(for id: UUID, estrogenArray: [MOEstrogen]) -> MOEstrogen? {
        if let estroIndex = estrogenArray.map({
            (estro: MOEstrogen) -> UUID? in
            return estro.getID()
        }).index(of: id) {
            return estrogenArray[estroIndex]
        }
        return nil
    }
    
    /// Returns the total non-nil dates in given estrogens.
    public static func datePlacedCount(for estrogenArray: [MOEstrogen]) -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.date != nil) ? 1 : 0
            return c + count
        })
    }
    
    /// Returns if every MOEstrogen's date is nil.
    public static func hasNoDates(_ estrogenArray: [MOEstrogen]) -> Bool {
        return (estrogenArray.filter() {
            $0.getDate() != nil
        }).count == 0
    }
    
    /// Returns if every MOEstrogen's site is nil.
    public static func hasNoSites(_ estrogenArray: [MOEstrogen]) -> Bool {
        return (estrogenArray.filter() {
            $0.getSite() != nil
        }).count == 0
    }
    
    /// Returns if every MOEstrogen's site and date are nil.
    public static func isEmpty(_ estrogenArray: [MOEstrogen]) -> Bool {
        return hasNoDates(estrogenArray) && hasNoSites(estrogenArray)
    }
    
    /// Returns if each MOEstrogen fromThisIndexOnward is empty.
    public static func isEmpty(_ estrogenArray: [MOEstrogen], fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if i >= 0 && i < estrogenArray.count {
                    let estro = estrogenArray[i]
                    if !estro.isEmpty() {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// Returns how many expired estrogens there are in the given estrogens.
    public static func expiredCount(_ estrogenArray: [MOEstrogen], intervalStr: String) -> Int {
        return estrogenArray.reduce(0, {
            count, estro in
            let c = (estro.isExpired(intervalStr)) ? 1 : 0
            return c + count
        })
    }
    
}
