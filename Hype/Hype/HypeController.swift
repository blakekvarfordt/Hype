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
        publicDB.save(hypeRecord) { (_, error) in
            
            if let error = error {
                print("There was an error with the stuff \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            self.hypes.append(hype)
            completion(true)
        }
    }
    // Read
    func fetchDemHypes(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordTypeKey, predicate: predicate)
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
    // Delete
}
