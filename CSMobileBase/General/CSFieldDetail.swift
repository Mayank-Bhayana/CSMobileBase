//
//  CSFieldDetail.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSFieldDetail: CustomStringConvertible {
    
    public var description: String
    
    public let label: String?
    public let type: CSFieldType?
    public let extraTypeInfo: String?
    public let pickListValues: [CSPickListValue]
    public let referenceTo: [String]
    public let relationshipName: String?
    
    internal enum Name: String {
        case label = "label"
        case type = "type"
        case extraTypeInfo = "extraTypeInfo"
        case pickListValues = "picklistValues"
        case relationshipName = "relationshipName"
        case referenceTo = "referenceTo"
    }
    
    internal init(json: JSON) {
        description = json.description
        label = json[Name.label.platformSpecificRawValue].string
        if let string: String = json[Name.type.platformSpecificRawValue].string?.uppercased() {
            type = CSFieldType(rawValue: string)
        }
        else {
            type = nil
        }
        extraTypeInfo = json[Name.extraTypeInfo.platformSpecificRawValue].string
        if let array: [JSON] = json[Name.pickListValues.platformSpecificRawValue].array {
            pickListValues = array.map { CSPickListValue(json: $0) }
        }
        else {
            pickListValues = []
        }
        if let array: [JSON] = json[Name.referenceTo.platformSpecificRawValue].array {
            referenceTo = array.map { $0.stringValue }
        }
        else {
            referenceTo = []
        }
        relationshipName = json[Name.relationshipName.platformSpecificRawValue].string
    }
    
}
