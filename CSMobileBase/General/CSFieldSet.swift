//
//  CSFieldSet.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation

open class CSFieldSet: CustomStringConvertible {
    
    open static func forRead() -> CSFieldSet {
        return CSFieldSet(isWrite: false)
    }
    
    open static func forWrite() -> CSFieldSet {
        return CSFieldSet(isWrite: true)
    }
    
    open static func forCreate() -> CSFieldSet {
        return CSFieldSet(isCreate: true)
    }
    
    open static func forUpdate() -> CSFieldSet {
        return CSFieldSet(isUpdate: true)
    }
    
    open var description: String {
        return array.joined(separator: ",")
    }
    
    open var array: [String] {
        return Array(fields.subtracting(excludes))
    }
    
    open var set: Set<String> {
        return Set(fields.subtracting(excludes))
    }
    
    fileprivate let isWrite: Bool
    fileprivate var isCreate: Bool = false
    fileprivate var isUpdate: Bool = false
    fileprivate var fields: Set<String> = Set()
    fileprivate var excludes: Set<String> = Set()
    
    fileprivate init(isWrite: Bool) {
        self.isWrite = isWrite
    }
    
    fileprivate init(isCreate: Bool) {
        self.isCreate = isCreate
        self.isWrite = isCreate
    }
    
    fileprivate init(isUpdate: Bool) {
        self.isUpdate = isUpdate
        self.isWrite = isUpdate
    }
    
    open func withField(_ name: String) -> CSFieldSet {
        fields.insert(name)
        return self
    }
    
    open func withRelationField(_ relation: String, name: String) -> CSFieldSet {
        fields.insert("\(relation).\(name)")
        return self
    }
    
    open func withObject(_ object: CSObject?) -> CSFieldSet {
        if let object: CSObject = object {
            for field: CSField in object.fields {
                if isWrite == false || isWritable(field) {
                    for name: String in names(field) {
                        _ = withField(name.platformCaseStringValue)
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
                    for name: String in names(field) {
                        withRelationField(relation, name: name)
                    }
                }
            }
        }
        return self
    }
    
    open func excludeField(_ name: String) -> CSFieldSet {
        excludes.insert(name)
        return self
    }
    
    fileprivate func names(_ field: CSField) -> [String] {
        var names: [String] = [field.name]
        if isWrite == false && field.type == CSFieldType.Reference {
            if let relationshipName: String = field.relationshipName, let relationshipField: String = field.relationshipField {
                names.append("\(relationshipName).\(CSRecord.Field.id.platformSpecificRawValue)")
                names.append("\(relationshipName).\(relationshipField)")
            }
        }
        return names
    }
    
    fileprivate func isWritable(_ field: CSField) -> Bool {
        if (field.isCreateable && field.isUpdateable) || (isCreate && field.isCreateable) || (isUpdate && field.isUpdateable) {
            return true
        }
        
        return false
    }
    
}
