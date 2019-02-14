//
//  CSFieldLayout.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSFieldLayout: CustomStringConvertible {
    
    public var description: String
    
    public let name: String
    public let label: String?
    public let type: CSFieldType?
    public let extraTypeInfo: CSExtraTypeInfo?
    public let defaultValue: String?
    public let isRequired: Bool
    public let isCreateable: Bool
    public let isUpdateable: Bool
    public let length: Int?
    public let scale: Int?
    public let options: [CSPickListValue]?
    public let referenceTo: String?
    public let relationshipName: String?
    public let relationshipField: String?
    public let stateOptions: [CSPickListValue]?
    public let countryOptions: [CSPickListValue]?
    public let streetField: String?
    public let cityField: String?
    public let stateCodeField: String?
    public let postalCodeField: String?
    public let countryCodeField: String?
    
    internal enum Name: String {
        case name = "Name"
        case label = "Label"
        case type = "Type"
        case extraTypeInfo = "ExtraTypeInfo"
        case defaultValue = "DefaultValue"
        case isRequired = "Required"
        case isCreateable = "Createable"
        case isUpdateable = "Updateable"
        case length = "Length"
        case scale = "Scale"
        case options = "PicklistValues"
        case referenceTo = "ReferenceTo"
        case relationshipName = "RelationshipName"
        case relationshipField = "RelationshipField"
        case stateOptions = "StatePicklistMap"
        case countryOptions = "CountryPicklistMap"
        case streetField = "Street"
        case cityField = "City"
        case stateCodeField = "State"
        case postalCodeField = "PostalCode"
        case countryCodeField = "Country"
    }
    
    internal init(json: JSON) {
        description = json.description
        name = json[Name.name.platformSpecificRawValue].stringValue
        label = json[Name.label.platformSpecificRawValue].string
        if let string: String = json[Name.type.platformSpecificRawValue].string {
            type = CSFieldType(rawValue: string)
        }
        else {
            type = nil
        }
        if let string: String = json[Name.extraTypeInfo.platformSpecificRawValue].string {
            extraTypeInfo = CSExtraTypeInfo(rawValue: string)
        }
        else {
            extraTypeInfo = nil
        }
        defaultValue = json[Name.defaultValue.platformSpecificRawValue].string
        isRequired = json[Name.isRequired.platformSpecificRawValue].boolValue
        isCreateable = json[Name.isCreateable.platformSpecificRawValue].boolValue
        isUpdateable = json[Name.isUpdateable.platformSpecificRawValue].boolValue
        if let length: String = json[Name.length.platformSpecificRawValue].string {
            self.length = Int(length)
        }
        else {
            self.length = nil
        }
        if let scale: String = json[Name.scale.platformSpecificRawValue].string {
            self.scale = Int(scale)
        }
        else {
            self.scale = nil
        }
        if let array: [JSON] = json[Name.options.platformSpecificRawValue].array {
            options = array.map { CSPickListValue(json: $0) }
        }
        else {
            options = nil
        }
        referenceTo = json[Name.referenceTo.platformSpecificRawValue].string
        relationshipName = json[Name.relationshipName.platformSpecificRawValue].string
        relationshipField = json[Name.relationshipField.platformSpecificRawValue].string
        if let array: [JSON] = json[Name.stateOptions.platformSpecificRawValue].array {
            stateOptions = array.map { CSPickListValue(json: $0) }
        }
        else {
            stateOptions = nil
        }
        if let array: [JSON] = json[Name.countryOptions.platformSpecificRawValue].array {
            countryOptions = array.map { CSPickListValue(json: $0) }
        }
        else {
            countryOptions = nil
        }
        streetField = json[Name.streetField.platformSpecificRawValue].string
        cityField = json[Name.cityField.platformSpecificRawValue].string
        stateCodeField = json[Name.stateCodeField.platformSpecificRawValue].string
        postalCodeField = json[Name.postalCodeField.platformSpecificRawValue].string
        countryCodeField  = json[Name.countryCodeField.platformSpecificRawValue].string
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }
    
}
