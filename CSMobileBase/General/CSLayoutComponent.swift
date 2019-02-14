//
//  CSLayoutComponent.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSLayoutComponent: CustomStringConvertible {
    
    public var description: String
    
    public let value: String?
    public let type: String?
    public let detail: CSFieldDetail?
    public let layoutComponents: [CSLayoutComponent]
    
    internal enum Name: String {
        case value = "value"
        case type = "type"
        case detail = "details"
        case layoutComponents = "components"
    }
    
    internal init(json: JSON) {
        description = json.description
        value = json[Name.value.platformSpecificRawValue].string
        type = json[Name.type.platformSpecificRawValue].string
        if let json: JSON = json[Name.detail.platformSpecificRawValue] {
            detail = CSFieldDetail(json: json)
        }
        else {
            detail = nil
        }
        if let array: [JSON] = json[Name.layoutComponents.platformSpecificRawValue].array {
            layoutComponents = array.map { CSLayoutComponent(json: $0) }
        }
        else {
            layoutComponents = []
        }
    }

}
    
