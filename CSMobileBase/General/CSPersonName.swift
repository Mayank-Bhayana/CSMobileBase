//
//  CSPersonName.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSPersonName {
    
    public var salutation: String?
    public var firstName: String?
    public var lastName: String?
    
    internal enum Name: String {
        case salutation = "Salutation"
        case firstName = "FirstName"
        case lastName = "LastName"
    }
    
    internal init(record: CSRecord?) {
        salutation = record?.getString(Name.salutation.platformSpecificRawValue)
        firstName = record?.getString(Name.firstName.platformSpecificRawValue)
        lastName = record?.getString(Name.lastName.platformSpecificRawValue)
    }
    
}
