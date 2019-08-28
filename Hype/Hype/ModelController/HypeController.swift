//
//  HypeController.swift
//  Hype
//
//  Created by Blake kvarfordt on 8/26/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation
import CloudKit


class HypeController {
    
    
    // Singletom
    static let shared = HypeController()
    
    // Source of truth
    var hypes: [Hype] = []
    let publicDB = CKContainer(identifier: "iCloud.com.blakekvarfordt.Hype").publicCloudDatabase
    
    // CRUD
    
    // Create
    func saveHype(with text: String, completion: @escaping (Bool) -> Void) {
        let hype = Hype(text: text)
        let hypeRecord = CKRecord(hype: hype)
        self.hypes.insert(hype, at: 0)
        publicDB.save(hypeRecord) { (_, error) in
            
            if let error = error {
                print("There was an error with the stuff \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    // Read
    func fetchDemHypes(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordTypeKey, predicate: predicate)
        
        let sortDescriptor = NSSortDescriptor(key: "Timestamp", ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error with the stuff \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            let hypes = records.compactMap({Hype(ckRecord: $0)})
            self.hypes = hypes
            completion(true)
        }
    }
    
    // Update
    func update(hype: Hype, with newText: String, completion: @escaping (Bool) -> Void ) {
        hype.text = newText
        hype.timestamp = Date()
       
        // get the hype to update = turn it into a ckrecord
        let modificationOp = CKModifyRecordsOperation(recordsToSave: [CKRecord(hype: hype)], recordIDsToDelete: nil)
        modificationOp.savePolicy = .changedKeys
        modificationOp.queuePriority = .veryHigh
        modificationOp.qualityOfService = .userInteractive
        modificationOp.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
            
            if let error = error {
                print("Error fetching: \(#function) \(error.localizedDescription)")
                completion(false); return
            }
            completion(true)
        }
        publicDB.add(modificationOp)
    }
    
    
    // Delete
    func remove(hype: Hype, completion: @escaping (Bool) -> Void) {
        
        // get the recordID that needs to be deleted
        guard let hypeRecord = hype.ckRecordID else { return }
        // conform to equatable to get firstIndex of method
        guard let firstIndex = self.hypes.firstIndex(of: hype) else { return }
        
        //remove out of source of truth
        hypes.remove(at: firstIndex)
        
        publicDB.delete(withRecordID: hypeRecord) { (recordID, error) in
            
            if let error = error {
                print("Error fetching: \(#function) \(error.localizedDescription)")
                completion(false); return
            }
            
            completion(true); return
        }
    }
    
    func subscribeToRemoteNotifications(completion: @escaping (Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        
        let subscription = CKQuerySubscription(recordType: Constants.recordTypeKey, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Hell Yeah. New Hype"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
    
        subscription.notificationInfo = notificationInfo
        
        
        publicDB.save(subscription) { (_, error) in
            
            
            if let error = error {
                print("Error with subscription \(error.localizedDescription)")
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
}
