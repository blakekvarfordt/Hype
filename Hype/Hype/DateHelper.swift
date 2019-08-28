//
//  DateHelper.swift
//  Hype
//
//  Created by Blake kvarfordt on 8/27/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation

class DateHelper {
    
    static let shared = DateHelper()
    
    // This ensures that this class can only be initialized once (singletone)
    private init () {}
    
    let dateFormatter = DateFormatter()
    
    func mediumStringFor(date: Date) -> String {
        dateFormatter.dateStyle = .medium
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
