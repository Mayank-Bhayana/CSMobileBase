//
//  CSField.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/27/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSField: CustomStringConvertible {
    
    public var description: String
    
    public let name: String
    public let type: CSFieldType?
    public let isCreateable: Bool
    public let isUpdateable: Bool
    public let referenceTo: String?
    public let relationshipName: String?
    public let relationshipField: String?
    
    internal enum Name: String {
        case name = "Name"
        case type = "Type"
        case isCreateable = "Createable"
        case isUpdateable = "Updateable"
        case referenceTo = "ReferenceTo"
        case relationshipName = "RelationshipName"
        case relationshipField = "RelationshipField"
    }
    
    internal init(json: JSON) {
        description = json.description
        name = json[Name.name.platformSpecificRawValue].stringValue
        if let string: String = json[Name.type.platformSpecificRawValue].string {
            type = CSFieldType(rawValue: string)
        }
        else {
            type = nil
        }
        isCreateable = json[Name.isCreateable.platformSpecificRawValue].boolValue
        isUpdateable = json[Name.isUpdateable.platformSpecificRawValue].boolValue
        referenceTo = json[Name.referenceTo.platformSpecificRawValue].string
        relationshipName = json[Name.relationshipName.platformSpecificRawValue].string
        relationshipField = json[Name.relationshipField.platformSpecificRawValue].string
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }

}
