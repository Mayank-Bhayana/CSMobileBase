//
//  CSObject.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/27/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSObject: CustomStringConvertible {
    
    public var description: String
    
    public let label: String?
    public let labelPlural: String?
    public let isAccessible: Bool
    public let isCreateable: Bool
    public let isUpdateable: Bool
    public let isDeletable: Bool
    public let isSearchable: Bool
    public let nameField: String?
    public let searchFields: [String]
    public let fields: [CSField]
    public let recordTypes: [CSRecordType]
    
    internal enum Name: String {
        case label = "Label"
        case labelPlural = "LabelPlural"
        case isAccessible = "Accessible"
        case isCreateable = "Createable"
        case isUpdateable = "Updateable"
        case isDeleteable = "Deletable"
        case isSearchable = "Searchable"
        case nameField = "Name"
        case fields = "FieldInfo"
        case searchFields = "SearchableFields"
        case recordTypes = "RecordTypeInfo"
    }
    
    internal init(json: JSON) {
        description = json.description
        label = json[Name.label.platformSpecificRawValue].string
        labelPlural = json[Name.labelPlural.platformSpecificRawValue].string
        isAccessible = json[Name.isAccessible.platformSpecificRawValue].boolValue
        isCreateable = json[Name.isCreateable.platformSpecificRawValue].boolValue
        isUpdateable = json[Name.isUpdateable.platformSpecificRawValue].boolValue
        isDeletable = json[Name.isDeleteable.platformSpecificRawValue].boolValue
        isSearchable = json[Name.isSearchable.platformSpecificRawValue].boolValue
        nameField = json[Name.nameField.platformSpecificRawValue].string
        if let array: [JSON] = json[Name.fields.platformSpecificRawValue].array {
            fields = array.map { CSField(json: $0) }
        }
        else {
            fields = []
        }
        if let array: [JSON] = json[Name.searchFields.platformSpecificRawValue].array {
            searchFields = array.map { $0.stringValue }
        }
        else {
            searchFields = []
        }
        if let dictionary: [String : JSON] = json[Name.recordTypes.platformSpecificRawValue].dictionary {
            recordTypes = Array(dictionary.values).map { CSRecordType(json: $0) }
        }
        else {
            recordTypes = []
        }
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }
    
}
