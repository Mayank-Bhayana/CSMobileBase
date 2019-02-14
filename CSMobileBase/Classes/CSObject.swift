//
//  CSObject.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation
import SwiftyJSON

open class CSObject: CustomStringConvertible  {
    
    enum Attribute: String {
        case nameField = "NameField"
        case id = "Id"
        case label = "Label"
        case labelPlural = "LabelPlural"
        case isAccessible = "Accessible"
        case isCreateable = "Createable"
        case isUpdateable = "Updateable"
        case isDeleteable = "Deletable"
        case isSearchable = "Searchable"
        case searchableFields = "SearchableFields"
        case recordTypes = "RecordTypeInfo"
        case fields = "FieldInfo"
    }
    
    open fileprivate(set) lazy var id: String = self.json[Attribute.id.rawValue].stringValue
    open fileprivate(set) lazy var nameField: String? = self.json[Attribute.nameField.rawValue].string
    open fileprivate(set) lazy var label: String? = self.json[Attribute.label.rawValue].string
    open fileprivate(set) lazy var labelPlural: String? = self.json[Attribute.labelPlural.rawValue].string
    open fileprivate(set) lazy var isAccessible: Bool = self.json[Attribute.isAccessible.rawValue].boolValue
    open fileprivate(set) lazy var isCreateable: Bool = self.json[Attribute.isCreateable.rawValue].boolValue
    open fileprivate(set) lazy var isUpdateable: Bool = self.json[Attribute.isUpdateable.rawValue].boolValue
    open fileprivate(set) lazy var isDeletable: Bool = self.json[Attribute.isDeleteable.rawValue].boolValue
    open fileprivate(set) lazy var isSearchable: Bool = self.json[Attribute.isSearchable.rawValue].boolValue
    open fileprivate(set) lazy var searchableFields: [String] = self.getSearchableFields()
    open fileprivate(set) lazy var recordTypes: [CSRecordType] = self.getRecordTypes()
    open fileprivate(set) lazy var fields: [CSField] = self.getFields()
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    open var description: String {
        return json.description
    }
    
    open func recordTypeForId(_ id: String) -> CSRecordType? {
        if let dictionary: [String : JSON] = json[Attribute.recordTypes.rawValue].dictionary {
            if let json: JSON = dictionary[id] {
                return CSRecordType(json: json)
            }
        }
        return nil
    }
    
    fileprivate func getSearchableFields() -> [String] {
        if let value: [JSON] = json[Attribute.searchableFields.rawValue].array {
            return value.map { $0.stringValue }
        }
        return []
    }
    
    fileprivate func getFields() -> [CSField] {
        if let value: [JSON] = json[Attribute.fields.rawValue].array {
            return value.map { CSField(json: $0) }
        }
        return []
    }
    
    fileprivate func getRecordTypes() -> [CSRecordType] {
        if let dictionary: [String : JSON] = json[Attribute.recordTypes.rawValue].dictionary {
            return dictionary.values.map { CSRecordType(json: $0) }
        }
        return []
    }
    
}

