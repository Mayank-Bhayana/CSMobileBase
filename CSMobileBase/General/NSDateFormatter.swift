//
//  DateFormatter.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/11/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SalesforceSDKCore

public extension DateFormatter {
    
    public convenience init(userAccount: SFUserAccount) {
        self.init()
        if UserDefaults.standard.bool(forKey: "salesforce_locale_preference") {
            locale = Locale(identifier: userAccount.idData.locale)
        }
        if UserDefaults.standard.bool(forKey: "salesforce_timezone_preference") {
            if let timezone: String = userAccount.idData.dictRepresentation["timezone"] as? String {
                timeZone = TimeZone(identifier: timezone)
            }
        }
    }
    
    public func stringFromDate(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        return string(from: date)
    }
    
    public func queryString(_ date: Date?) -> String? {
        if let date: Date = date {
            timeZone = TimeZone(abbreviation: "GMT")
            dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return string(from: date)
        }
        return nil
    }
    
}
