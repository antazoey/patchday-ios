//
//  PDDataMigrater.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import CoreData

public let oldEntityNames = ["PatchA", "PatchB", "PatchC", "PatchD"]
public let oldEntityAttrs = ["datePlaced", "location"]
public let oldDefaultSiteNameConvert = ["Right Buttock" : "Right Glute",
                                       "Left Buttock" : "Left Glute",
                                       "Right Stomach" : "Right Abdomen",
                                       "Left Stomach" : "Left Abdomen"]

class PDDataMigrater: NSObject {
    
    private static func loadOldEstro(at i: Int) -> MOOldEstro? {
        var oldestro: MOOldEstro?
        let fetchRequest = NSFetchRequest<MOOldEstro>(entityName: oldEntityNames[i])
        fetchRequest.propertiesToFetch = oldEntityAttrs
        do {
            let requestedMO = try ScheduleController.persistentContainer.viewContext.fetch(fetchRequest)
            if requestedMO.count > 0 {
                oldestro = requestedMO[0]
            }
        }
        catch {
            print("Data Fetch Request Failed")
    }
        return oldestro
    }
    
    public static func migrateEstros(newEstros: inout [MOEstrogen]) {
        
        // Load old ones
        var oldestros: [MOOldEstro] = []
        for i in 0..<oldEntityNames.count {
            if let old = PDDataMigrater.loadOldEstro(at: i) {
                oldestros.append(old)
            }
        }
        
        for i in 0..<newEstros.count {
            if i < oldestros.count {
                let oldestro = oldestros[i]
                let newestro = newEstros[i]
                if let d = oldestro.datePlaced {
                    newestro.date = d
                }
                if let s = oldestro.location {
                    if let cs = oldDefaultSiteNameConvert[s] , let site = ScheduleController.siteController.getSite(for: cs) {
                        newestro.setSite(with: site)
                    }
                    else {
                        newestro.setSiteBackup(to: s)
                    }
                }
            }
        }
    }
    
    static let includes = ["i_tb", "i_pg"]
    static let tbts = ["tb_time", "tb_time2"]
    static let pgts = ["pg_time", "pg_time2"]
    static let dailies = ["tb_daily", "pg_daily"]
    static let rs = ["rTB", "rPG"]
    static let defaults = UserDefaults.standard
    
    public static func migratePills(newPills: inout [MOPill]) {
        
        if newPills.count < 2 {
            return
        }
        
        // TB
        var tb_was_removed: Bool = false
        if let inc_tb = defaults.object(forKey: includes[0]) as? Bool {
            if inc_tb {
                let new_tb = newPills[0]
                if let t1 = defaults.object(forKey: tbts[0]) as? NSDate {
                    new_tb.setTime1(with: t1 as NSDate)
                }
                if let d = defaults.object(forKey: dailies[0]) as? Int16 {
                    new_tb.setTimesaday(with: d)
                    if d >= 2, let t2 = defaults.object(forKey: tbts[1]) as? NSDate {
                        new_tb.setTime2(with: t2)
                    }
                }
                if let r = defaults.object(forKey: rs[0]) as? Bool {
                    new_tb.setNotify(with: r)
                }
            }
            else {
                newPills.remove(at: 0)
                tb_was_removed = true
            }
        }

        // PG
        if let inc_pg = defaults.object(forKey: includes[1]) as? Bool {
            let i = tb_was_removed ? 0 : 1
            if inc_pg {
                let new_pg = newPills[i]
                    if let t1 = defaults.object(forKey: pgts[0]) as? NSDate {
                        new_pg.setTime1(with: t1)
                    }
                    if let d = defaults.object(forKey: dailies[1]) as? Int16 {
                        new_pg.setTimesaday(with: d)
                        if d >= 2, let t2 = defaults.object(forKey: pgts[1]) as? NSDate {
                            new_pg.setTime2(with: t2)
                        }
                    }
                    if let r = defaults.object(forKey: rs[1]) as? Bool {
                        new_pg.setNotify(with: r)
                    }
            }
            else {
                newPills.remove(at: i)
            }
        }
        
    }

}

