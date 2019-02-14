//
//  Date.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/11/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation

internal extension Date {
    
    internal func toGMT() -> Date {
        let timeZone: TimeZone = TimeZone.autoupdatingCurrent
        let seconds: NSInteger = -timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(seconds))
    }
    
}
