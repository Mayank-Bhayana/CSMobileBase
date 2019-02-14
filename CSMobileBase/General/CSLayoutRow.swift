//
//  CSLayoutRow.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSLayoutRow: CustomStringConvertible {
    
    public var description: String
    
    public let layoutItems: [CSLayoutItem]
    
    internal enum Name: String {
        case layoutItems = "layoutItems"
    }
    
    internal init(json: JSON) {
        description = json.description
        if let array: [JSON] = json[Name.layoutItems.platformSpecificRawValue].array {
            layoutItems = array.map { CSLayoutItem(json: $0) }
        }
        else {
            layoutItems = []
        }
    }
    
}
