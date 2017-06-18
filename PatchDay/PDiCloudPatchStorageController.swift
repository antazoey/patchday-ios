//
//  File.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import CloudKit

class PDiCloudPatchStorageController {

    var patchContainer: CKContainer = { return CKContainer(identifier: "iCloud.com.juliyasmith.patchday") }()
    
    // MARK: - public patch container
    
    public func createAndSavePatchRecord(patchIndex: Int, location: String, datePlaced: Date) {
        let patchRec = createPatchRecord(patchIndex: patchIndex, location: location, datePlaced: datePlaced)
        savePatchRecord(patchRecord: patchRec!)
    }
    
    public func savePatchRecord(patchRecord: CKRecord) {
        let userPatchDatabase: CKDatabase = patchContainer.privateCloudDatabase
        userPatchDatabase.save(patchRecord) {
            (record, error) in
            if error != nil {
                // Insert error handling
                return
            }
        }
    }
    
    public func createPatchRecord(patchIndex: Int, location: String, datePlaced: Date) -> CKRecord? {
        var patchRecord: CKRecord?
        let patchRecordID = createPatchRecordID(patchIndex: patchIndex)
        patchRecord = CKRecord(recordType: "Patch", recordID: patchRecordID)
        patchRecord!["location"] = location as NSString
        patchRecord!["datePlaced"] = datePlaced as NSDate
        return patchRecord
    }
    
    // MARK: - private patch record
    
    // called by creatPatchRecord()
    private func createPatchRecordID(patchIndex: Int) -> CKRecordID {
        return CKRecordID(recordName: PatchDayStrings.patchEntityNames[patchIndex])
    }
    
}
