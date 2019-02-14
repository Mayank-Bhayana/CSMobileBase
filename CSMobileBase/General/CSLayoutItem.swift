//
//  CSLayoutItem.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSLayoutItem: CustomStringConvertible {
    
    public var description: String
    
    public let label: String?
    public let required: Bool
    public let editableForUpdate: Bool
    public let editableForNew: Bool
    public let layoutComponents: [CSLayoutComponent]
    
    internal enum Name: String {
        case label = "label"
        case required = "required"
        case editableForUpdate = "editableForUpdate"
        case editableForNew = "editableForNew"
        case layoutComponents = "layoutComponents"
    }
    
    internal init(json: JSON) {
        description = json.description
        label = json[Name.label.platformSpecificRawValue].string
        required = json[Name.required.platformSpecificRawValue].boolValue
        editableForUpdate = json[Name.editableForUpdate.platformSpecificRawValue].boolValue
        editableForNew = json[Name.editableForNew.platformSpecificRawValue].boolValue
        if let array: [JSON] = json[Name.layoutComponents.platformSpecificRawValue].array {
            layoutComponents = array.map { CSLayoutComponent(json: $0) }
        }
        else {
            layoutComponents = []
        }
    }
    
}
