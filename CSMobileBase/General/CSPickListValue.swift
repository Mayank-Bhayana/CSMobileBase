//
//  CSPickListValue.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/29/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSPickListValue: CustomStringConvertible {
    
    public var description: String
    
    public let value: String?
    public let label: String?
    public let isActive: Bool
    public let defaultValue: Bool
    public let validFor: String?

    internal enum Name: String {
        case value = "Value"
        case label = "Label"
        case isActive = "Active"
        case defaultValue = "DefaultValue"
        case validFor = "ValidFor"
    }
    
    internal init(json: JSON) {
        description = json.description
        value = json[Name.value.platformSpecificRawValue].string
        label = json[Name.label.platformSpecificRawValue].string
        isActive = json[Name.isActive.platformSpecificRawValue].boolValue
        defaultValue = json[Name.defaultValue.platformSpecificRawValue].boolValue
        validFor = json[Name.validFor.platformSpecificRawValue].string
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }

}
