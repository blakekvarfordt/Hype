//
//  User.swift
//  Hype
//
//  Created by Blake kvarfordt on 8/29/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation
import CloudKit

struct UserStrings {
    static let typeKey = "User"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let emailKey = "email"
    static let appleUserReferenceKey = "appleUserReference"
}

class User {
    var firstName: String
    var lastName: String
    var email: String
    var appleUserReference: CKRecord.Reference
    var ckRecordID: CKRecord.ID
    
    // Step one init the object
    init(firstName: String, lastName: String, email: String, appleUserReference: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.appleUserReference = appleUserReference
        self.ckRecordID = ckRecordID
    }
    
    // Step 3 fetch and init object from iCloud
    init?(ckRecord: CKRecord) {
        guard let firstName = ckRecord[UserStrings.firstNameKey] as? String,
        let lastName = ckRecord[UserStrings.lastNameKey] as? String,
            let email = ckRecord[UserStrings.emailKey] as? String,
        let appleUserReference = ckRecord[UserStrings.appleUserReferenceKey] as? CKRecord.Reference else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.appleUserReference = appleUserReference
        self.ckRecordID = ckRecord.recordID
    }
}

extension CKRecord {
    
    // Step 2 save object to iCloud
    convenience init(user: User) {
        self.init(recordType: UserStrings.typeKey, recordID: user.ckRecordID)
        setValue(user.firstName, forKey: UserStrings.firstNameKey)
        setValue(user.lastName, forKey: UserStrings.lastNameKey)
        setValue(user.email, forKey: UserStrings.emailKey)
        
    }
}


