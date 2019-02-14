//
//  CSField.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON


open class CSField: CustomStringConvertible  {
    
    enum Attribute: String {
        case name = "Name"
        case type = "Type"
        case createable = "Createable"
        case updateable = "Updateable"
        case referenceTo = "ReferenceTo"
        case relationshipName = "RelationshipName"
        case relationshipField = "RelationshipField"
    }
    
    public enum FieldType: String {
        case String = "STRING"
        case Integer = "INTEGER"
        case Double = "DOUBLE"
        case Percent = "PERCENT"
        case Currency = "CURRENCY"
        case Boolean = "BOOLEAN"
        case TextArea = "TEXTAREA"
        case PickList = "PICKLIST"
        case MultiPickList = "MULTIPICKLIST"
        case Date = "DATE"
        case DateTime = "DATETIME"
        case Phone = "PHONE"
        case Email = "EMAIL"
        case Url = "URL"
        case Address = "ADDRESS"
        case Reference = "REFERENCE"
    }
    
    open fileprivate(set) lazy var name: String = self.json[Attribute.name.rawValue].stringValue
    open fileprivate(set) lazy var type: FieldType? = self.getType()
    open fileprivate(set) lazy var createable: Bool = self.json[Attribute.createable.rawValue].boolValue
    open fileprivate(set) lazy var updateable: Bool = self.json[Attribute.updateable.rawValue].boolValue
    open fileprivate(set) lazy var referenceTo: String? = self.json[Attribute.referenceTo.rawValue].string
    open fileprivate(set) lazy var relationshipName: String? = self.json[Attribute.relationshipName.rawValue].string
    open fileprivate(set) lazy var relationshipField: String? = self.json[Attribute.relationshipField.rawValue].string
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    fileprivate func getType() -> FieldType? {
        if let string: String = json[Attribute.type.rawValue].string {
            return FieldType(rawValue: string)
        }
        return nil
    }
    
}

