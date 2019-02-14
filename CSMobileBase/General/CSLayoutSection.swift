//
//  CSLayoutSection.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CSLayoutSection: CustomStringConvertible {
    
    public var description: String
    
    public let heading: String?
    public let layoutRows: [CSLayoutRow]
 
    internal enum Name: String {
        case heading = "heading"
        case layoutRows = "layoutRows"
    }
    
    internal init(json: JSON) {
        description = json.description
        heading = json[Name.heading.platformSpecificRawValue].string
        if let array: [JSON] = json[Name.layoutRows.platformSpecificRawValue].array {
            layoutRows = array.map { CSLayoutRow(json: $0) }
        }
        else {
            layoutRows = []
        }
    }
    
}
