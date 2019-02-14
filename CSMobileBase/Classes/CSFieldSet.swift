//
//  CSFieldSet.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//

import Foundation

open class CSFieldSet {
    
    open static func forRead() -> CSFieldSet {
        return CSFieldSet(isWrite: false)
    }
    
    open static func forWrite() -> CSFieldSet {
        return CSFieldSet(isWrite: true)
    }
    
    open var description: String {
        return Array(fields).joined(separator: ",")
    }
    
    open var array: [String] {
        return Array(fields)
    }
    
    fileprivate let isWrite: Bool
    fileprivate var fields: Set<String> = Set()
    
    fileprivate init(isWrite: Bool) {
        self.isWrite = isWrite
    }
    
    open func withField(_ field: String) -> CSFieldSet {
        fields.insert(field)
        return self
    }
    
    open func withRelationField(_ relation: String, field: String) -> CSFieldSet {
        fields.insert("\(relation).\(field)")
        return self
    }
    
    open func withObject(_ object: CSObject?) -> CSFieldSet {
        if let object: CSObject = object {
            for field: CSField in object.fields {
                if isWrite == false || isWritable(field) {
                    for fieldName: String in fieldNames(field) {
                        withField(fieldName)
                    }
                }
            }
        }
        return self
    }
    
    open func withRelationObject(_ relation: String, object: CSObject?) -> CSFieldSet {
        if let object: CSObject = object {
            for field: CSField in object.fields {
                if isWrite == false {
                    for fieldName: String in fieldNames(field) {
                        withRelationField(relation, field: fieldName)
                    }
                }
            }
        }
        return self
    }
    
    fileprivate func fieldNames(_ field: CSField) -> [String] {
        var fieldNames: [String] = [field.name]
        if isWrite == false && field.type == CSField.FieldType.Reference {
            if let relationshipName: String = field.relationshipName, let relationshipField: String = field.relationshipField {
                fieldNames.append("\(relationshipName).\(CSRecord.Field.id.rawValue)")
                fieldNames.append("\(relationshipName).\(relationshipField)")
            }
        }
        return fieldNames
    }
    
    fileprivate func isWritable(_ field: CSField) -> Bool {
        return field.updateable && field.createable
    }
    
}

