//
//  CSFieldLayout.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSFieldLayout: CustomStringConvertible {
    
    enum Attribute: String {
        case name = "Name"
        case label = "Label"
        case type = "Type"
        case extraTypeInfo = "ExtraTypeInfo"
        case required = "Required"
        case createable = "Createable"
        case updateable = "Updateable"
        case length = "Length"
        case scale = "Scale"
        case options = "PicklistValues"
        case referenceTo = "ReferenceTo"
        case relationshipName = "RelationshipName"
        case relationshipField = "RelationshipField"
        case countryOptions = "CountryPicklistMap"
        case stateOptions = "StatePicklistMap"
        case streetField = "Street"
        case cityField = "City"
        case stateField = "State"
        case postalCodeField = "PostalCode"
        case countryField = "Country"
    }
    
    public enum ExtraType: String {
        case PersonName = "personname"
    }
    
    open fileprivate(set) lazy var name: String = self.json[Attribute.name.rawValue].stringValue
    open fileprivate(set) lazy var label: String? = self.json[Attribute.label.rawValue].string
    open fileprivate(set) lazy var type: CSField.FieldType? = self.getType()
    open fileprivate(set) lazy var extraTypeInfo: ExtraType? = self.getExtraTypeInfo()
    open fileprivate(set) lazy var required: Bool = self.json[Attribute.required.rawValue].boolValue
    open fileprivate(set) lazy var createable: Bool = self.json[Attribute.createable.rawValue].boolValue
    open fileprivate(set) lazy var updateable: Bool = self.json[Attribute.updateable.rawValue].boolValue
    open fileprivate(set) lazy var length: Int? = self.json[Attribute.length.rawValue].int
    open fileprivate(set) lazy var scale: Int? = self.json[Attribute.scale.rawValue].int
    open fileprivate(set) lazy var options: [CSOption]? = self.getOptions(Attribute.options)
    open fileprivate(set) lazy var referenceTo: String? = self.json[Attribute.referenceTo.rawValue].string
    open fileprivate(set) lazy var relationshipName: String? = self.json[Attribute.relationshipName.rawValue].string
    open fileprivate(set) lazy var relationshipField: String? = self.json[Attribute.relationshipField.rawValue].string
    open fileprivate(set) lazy var countryOptions: [CSOption]? = self.getOptions(Attribute.countryOptions)
    open fileprivate(set) lazy var stateOptions: [CSOption]? = self.getOptions(Attribute.stateOptions)
    open fileprivate(set) lazy var streetField: String? = self.json[Attribute.streetField.rawValue].string
    open fileprivate(set) lazy var cityField: String? = self.json[Attribute.cityField.rawValue].string
    open fileprivate(set) lazy var stateField: String? = self.json[Attribute.stateField.rawValue].string
    open fileprivate(set) lazy var postalCodeField: String? = self.json[Attribute.postalCodeField.rawValue].string
    open fileprivate(set) lazy var countryField: String? = self.json[Attribute.countryField.rawValue].string
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    fileprivate func getType() -> CSField.FieldType? {
        if let string: String = json[Attribute.type.rawValue].string {
            return CSField.FieldType(rawValue: string)
        }
        return nil
    }
    
    fileprivate func getExtraTypeInfo() -> ExtraType? {
        if let string: String = json[Attribute.extraTypeInfo.rawValue].string {
            return ExtraType(rawValue: string)
        }
        return nil
    }
    
    fileprivate func getOptions(_ attribute: Attribute) -> [CSOption]? {
        if let value: [JSON] = json[attribute.rawValue].array {
            return value.map { CSOption(json: $0) }
        }
        return nil
    }
    
}

