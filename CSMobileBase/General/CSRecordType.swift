//
//  CSRecordType.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/27/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSRecordType: CustomStringConvertible {
    
    public var description: String
    
    public let id: String
    public let label: String?
    public let isAvailable: Bool
    
    internal enum Name: String {
        case id = "Id"
        case label = "Label"
        case isAvailable = "IsAvailable"
    }
    
    internal init(json: JSON) {
        description = json.description
        id = json[Name.id.platformSpecificRawValue].stringValue
        label = json[Name.label.platformSpecificRawValue].string
        isAvailable = json[Name.isAvailable.platformSpecificRawValue].boolValue
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }
    
}
