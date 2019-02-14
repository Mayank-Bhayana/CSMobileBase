//
//  CSAddress.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/22/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSAddress {
    
    public var description: String
    
    public var street: String?
    public var city: String?
    public var stateCode: String?
    public var postalCode: String?
    public var countryCode: String?
    
    internal enum Name: String {
        case street = "street"
        case city = "city"
        case stateCode = "stateCode"
        case postalCode = "postalCode"
        case countryCode = "countryCode"
    }
    
    internal var dictionary: [String : AnyObject] {
        var dictionary: [String : AnyObject] = [:]
        dictionary[Name.street.platformSpecificRawValue] = street as AnyObject?
        dictionary[Name.city.platformSpecificRawValue] = city as AnyObject?
        dictionary[Name.stateCode.platformSpecificRawValue] = stateCode as AnyObject?
        dictionary[Name.postalCode.platformSpecificRawValue] = postalCode as AnyObject?
        dictionary[Name.countryCode.platformSpecificRawValue] = countryCode as AnyObject?
        return dictionary
    }
    
    internal init(json: JSON) {
        description = json.description
        street = json[Name.street.platformSpecificRawValue].string
        city = json[Name.city.platformSpecificRawValue].string
        stateCode = json[Name.stateCode.platformSpecificRawValue].string
        postalCode = json[Name.postalCode.platformSpecificRawValue].string
        countryCode = json[Name.countryCode.platformSpecificRawValue].string
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }

}
