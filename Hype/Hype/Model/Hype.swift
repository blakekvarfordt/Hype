//
//  Hype.swift
//  Hype
//
//  Created by Blake kvarfordt on 8/26/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
    static let recordTypeKey = "Hype"
    static let recordTextKey = "Text"
    static let recordTimestampKey = "Timestamp"
}
class Hype {
    var text: String
    var timestamp: Date
    var ckRecordID: CKRecord.ID?
    
    init(text: String, timestamp: Date = Date()) {
        self.text = text
        self.timestamp = timestamp
    }
}


extension CKRecord {
    // Create a CKRecord from a Hype
    convenience init(hype: Hype) {
        self.init(recordType: Constants.recordTypeKey, recordID: hype.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString))
        self.setValue(hype.text, forKey: Constants.recordTextKey)
        self.setValue(hype.timestamp, forKey: Constants.recordTimestampKey)
        
        hype.ckRecordID = recordID
    }
}

extension Hype {
    // Create a Hype from CKRecord
    convenience init?(ckRecord: CKRecord) {
        guard let hypeText = ckRecord[Constants.recordTextKey] as? String, let timestamp = ckRecord[Constants.recordTimestampKey] as? Date else { return nil }
        self.init(text: hypeText, timestamp: timestamp)
        ckRecordID = ckRecord.recordID
        
        
    }
}

extension Hype: Equatable {
    
     static func == (lhs: Hype, rhs: Hype) -> Bool {
        
        return lhs.text == rhs.text && lhs.timestamp == rhs.timestamp && lhs.ckRecordID == rhs.ckRecordID
        
    }
    
}
